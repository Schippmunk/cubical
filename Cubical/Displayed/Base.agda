
{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.Displayed.Base where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Equiv

open import Cubical.Data.Sigma

open import Cubical.Relation.Binary

private
  variable
    ℓ ℓA ℓA' ℓ≅A ℓB ℓB' ℓ≅B ℓC ℓ≅C : Level

record UARel (A : Type ℓA) (ℓ≅A : Level) : Type (ℓ-max ℓA (ℓ-suc ℓ≅A)) where
  no-eta-equality
  constructor uarel
  field
    _≅_ : A → A → Type ℓ≅A
    ua : (a a' : A) → (a ≅ a') ≃ (a ≡ a')
  ρ : (a : A) → a ≅ a
  ρ a = invEq (ua a a) refl
  ≅→≡ : {a a' : A} (p : a ≅ a') → a ≡ a'
  ≅→≡ {a} {a'} p = equivFun (ua a a') p
  ≡→≅ : {a a' : A} (p : a ≡ a') → a ≅ a'
  ≡→≅ {a} {a'} p = equivFun (invEquiv (ua a a')) p

open BinaryRelation

-- another constructor for UARel using contractibility of relational singletons
make-𝒮 : {A : Type ℓA} {ℓ≅A : Level} {_≅_ : A → A → Type ℓ≅A}
          (ρ : isRefl _≅_) (contrTotal : contrRelSingl _≅_) → UARel A ℓ≅A
UARel._≅_ (make-𝒮 {_≅_ = _≅_} _ _) = _≅_
UARel.ua (make-𝒮 {_≅_ = _≅_} ρ c) = contrRelSingl→isUnivalent _≅_ ρ c

record DUARel {A : Type ℓA} {ℓ≅A : Level} (𝒮-A : UARel A ℓ≅A)
              (B : A → Type ℓB) (ℓ≅B : Level) : Type (ℓ-max (ℓ-max ℓA ℓB) (ℓ-max ℓ≅A (ℓ-suc ℓ≅B))) where
  no-eta-equality
  constructor duarel
  open UARel 𝒮-A

  field
    _≅ᴰ⟨_⟩_ : {a a' : A} → B a → a ≅ a' → B a' → Type ℓ≅B
    uaᴰ : {a : A} → (b b' : B a) → (b ≅ᴰ⟨ ρ a ⟩ b') ≃ (b ≡ b')
  ρᴰ : {a : A} → (b : B a) → b ≅ᴰ⟨ ρ a ⟩ b
  ρᴰ {a} b = invEq (uaᴰ b b) refl

make-𝒮ᴰ : {A : Type ℓA} {𝒮-A : UARel A ℓ≅A}
          {B : A → Type ℓB}
          (_≅ᴰ⟨_⟩_ : {a a' : A} → B a → UARel._≅_ 𝒮-A a a' → B a' → Type ℓ≅B)
          (ρᴰ : {a : A} → isRefl _≅ᴰ⟨ UARel.ρ 𝒮-A a ⟩_)
          (contrTotal : (a : A) → contrRelSingl _≅ᴰ⟨ UARel.ρ 𝒮-A a ⟩_)
          → DUARel 𝒮-A B ℓ≅B
DUARel._≅ᴰ⟨_⟩_ (make-𝒮ᴰ _≅ᴰ⟨_⟩_ ρᴰ contrTotal) = _≅ᴰ⟨_⟩_
DUARel.uaᴰ (make-𝒮ᴰ {𝒮-A = 𝒮-A} _≅ᴰ⟨_⟩_ ρᴰ contrTotal) {a} b b'
  = contrRelSingl→isUnivalent (_≅ᴰ⟨ UARel.ρ 𝒮-A a ⟩_) (ρᴰ {a}) (contrTotal a) b b'

private
  total : {A : Type ℓA} {ℓ≅A : Level} {𝒮-A : UARel A ℓ≅A}
          {B : A → Type ℓB} {ℓ≅B : Level}
          (𝒮ᴰ-B : DUARel 𝒮-A B ℓ≅B)
          → UARel (Σ A B) (ℓ-max ℓ≅A ℓ≅B)
  total {A = A} {ℓ≅A = ℓ≅A} {𝒮-A = 𝒮-A} {B = B} {ℓ≅B = ℓ≅B} 𝒮ᴰ-B =
    make-𝒮 ρΣ c
    where
      open UARel 𝒮-A
      open DUARel 𝒮ᴰ-B
      _≅Σ_ : Σ A B → Σ A B → Type (ℓ-max ℓ≅A ℓ≅B)
      (a , b) ≅Σ (a' , b') = Σ[ p ∈ a ≅ a' ] (b ≅ᴰ⟨ p ⟩ b')
      ρΣ : isRefl _≅Σ_
      ρΣ (a , b) = ρ a , ρᴰ b
      c : contrRelSingl _≅Σ_
      c (a , b) = cab , h
        where
          hA : contrRelSingl _≅_
          hA = isUnivalent→contrRelSingl _≅_ ua
          cab : relSinglAt _≅Σ_ (a , b)
          cab = (a , b) , ρΣ (a , b)
          hB : contrRelSingl (λ c c' → c ≅ᴰ⟨ ρ a ⟩ c')
          hB = isUnivalent→contrRelSingl _ uaᴰ
          g : (b' : B a) (q : b ≅ᴰ⟨ ρ a ⟩ b') → cab ≡ ((a , b') , ρ a , q)
          g b' q = J (λ w _ → cab ≡ ((a , fst w) , ρ a , snd w))
                     refl (isContr→isProp (hB b) (b , ρᴰ b) (b' , q))
          k : (a' : A) (p : a ≅ a') (b' : B a') (q : b ≅ᴰ⟨ p ⟩ b') → cab ≡ ((a' , b') , (p , q))
          k a' p = J (λ w _ → (b' : B (fst w)) (q : b ≅ᴰ⟨ snd w ⟩ b') → cab ≡ ((fst w , b') , (snd w , q)))
                     g (isContr→isProp (hA a) (a , ρ a) (a' , p))
          h : (w : relSinglAt _≅Σ_ (a , b)) → cab ≡ w
          h ((a' , b') , (p , q)) = k a' p b' q

-- total using copatterns
∫ : {A : Type ℓA} {ℓ≅A : Level} {𝒮-A : UARel A ℓ≅A}
        {B : A → Type ℓB} {ℓ≅B : Level}
        (𝒮ᴰ-B : DUARel 𝒮-A B ℓ≅B)
        → UARel (Σ A B) (ℓ-max ℓ≅A ℓ≅B)
UARel._≅_ (∫ 𝒮ᴰ-B) = UARel._≅_ (total 𝒮ᴰ-B)
UARel.ua (∫ 𝒮ᴰ-B) = UARel.ua (total 𝒮ᴰ-B)

module _ {A : Type ℓA} {ℓ≅A : Level} (𝒮-A : UARel A ℓ≅A) where
  open UARel 𝒮-A
  J-UARel : {a : A}
            (P : (a' : A) → {p : a ≡ a'} → Type ℓ)
            (d : P a {refl})
            {a' : A}
            (p : a ≅ a')
            → P a' {≅→≡ p}
  J-UARel {a} P d {a'} p
    = J (λ y q → P y {q})
        d
        (≅→≡ p)


Lift-𝒮ᴰ : {A : Type ℓA} (𝒮-A : UARel A ℓ≅A)
        {B : A → Type ℓB}
        {ℓ≅B : Level}
        (𝒮ᴰ-B : DUARel 𝒮-A B ℓ≅B)
        {C : A → Type ℓC}
        (𝒮ᴰ-C : DUARel 𝒮-A C ℓ≅C)
        → DUARel (∫ 𝒮ᴰ-C) (λ (a , _) → B a) ℓ≅B
Lift-𝒮ᴰ {A = A} 𝒮-A {B} {ℓ≅B} 𝒮ᴰ-B {C} 𝒮ᴰ-C
  = make-𝒮ᴰ _≅'⟨_⟩_ (λ {(a , c)} b → r {(a , c)} b) cont
  where
    open UARel 𝒮-A renaming (ρ to ρA)
    open DUARel 𝒮ᴰ-B renaming (_≅ᴰ⟨_⟩_ to _≅B⟨_⟩_ ; uaᴰ to uaB ; ρᴰ to ρB)
    open DUARel 𝒮ᴰ-C renaming (_≅ᴰ⟨_⟩_ to _≅C⟨_⟩_ ; uaᴰ to uaC ; ρᴰ to ρC)
    open UARel (∫ 𝒮ᴰ-C) renaming (_≅_ to _≅∫_ ; ua to ua∫ ; ρ to ρ∫)
    _≅'⟨_⟩_ : {(a , c) (a' , c') : Σ A C} → B a → Σ[ p ∈ a ≅ a' ] (c ≅C⟨ p ⟩ c') → B a' → Type ℓ≅B
    b ≅'⟨ p , q ⟩ b' = b ≅B⟨ p ⟩ b'
    r : {(a , c) : Σ A C} → (b : B a) → b ≅'⟨ ρ∫ (a , c) ⟩ b
    r {(a , c)} b = subst (λ q → b ≅'⟨ q ⟩ b)
                          (sym (transportRefl (ρA a , ρC c)))
                          (ρB b)
    cont : ((a , c) : Σ A C) → (b : B a) → isContr (Σ[ b' ∈ B a ] (b ≅'⟨ ρ∫ (a , c) ⟩ b'))
    cont (a , c) b = center , k
      where
        center : Σ[ b' ∈ B a ] (b ≅'⟨ ρ∫ (a , c) ⟩ b')
        center = b , r {(a , c)} b
        h : contrRelSingl λ b b' → b ≅B⟨ ρA a ⟩ b'
        h = isUnivalent→contrRelSingl _ uaB
        h' : contrRelSingl λ b b' → b ≅'⟨ ρ∫ (a , c) ⟩ b'
        h' = subst (λ q → contrRelSingl λ b b' → b ≅'⟨ q ⟩ b')
                   (sym (transportRefl (ρA a , ρC c)))
                   h
        g : (b' : B a) → (p : b ≅'⟨ ρ∫ (a , c) ⟩ b') → center ≡ (b' , p)
        g b' p = J (λ w _ → center ≡ w)
                   refl
                   (isContr→isProp (h' b) center (b' , p))
        k : ((b' , p) : Σ[ b' ∈ B a ] (b ≅'⟨ ρ∫ (a , c) ⟩ b')) → center ≡ (b' , p)
        k (b' , p) = g b' p



splitTotal-𝒮ᴰ : {A : Type ℓA} (𝒮-A : UARel A ℓ≅A)
                {B : A → Type ℓB} {ℓ≅B : Level} (𝒮ᴰ-B : DUARel 𝒮-A B ℓ≅B)
                {C : Σ A B → Type ℓC} {ℓ≅C : Level} (𝒮ᴰ-C : DUARel (∫ 𝒮ᴰ-B) C ℓ≅C)
                → DUARel 𝒮-A
                         (λ a → Σ[ b ∈ B a ] C (a , b))
                         (ℓ-max ℓ≅B ℓ≅C)
splitTotal-𝒮ᴰ {A = A} 𝒮-A {B} {ℓ≅B} 𝒮ᴰ-B {C} {ℓ≅C} 𝒮ᴰ-C
  = make-𝒮ᴰ _≅S⟨_⟩_ r cont
  where
    open UARel 𝒮-A renaming (ρ to ρA)
    open DUARel 𝒮ᴰ-B renaming (_≅ᴰ⟨_⟩_ to _≅B⟨_⟩_ ; uaᴰ to uaB ; ρᴰ to ρB)
    open DUARel 𝒮ᴰ-C renaming (_≅ᴰ⟨_⟩_ to _≅C⟨_⟩_ ; uaᴰ to uaC ; ρᴰ to ρC)
    _≅S⟨_⟩_ : {a a' : A}
              → ((b , c) : Σ[ b ∈ B a ] C (a , b))
              → (p : a ≅ a')
              → ((b' , c') : Σ[ b' ∈ B a' ] C (a' , b'))
              → Type (ℓ-max ℓ≅B ℓ≅C)
    (b , c) ≅S⟨ p ⟩ (b' , c') = Σ[ q ∈ b ≅B⟨ p ⟩ b' ] c ≅C⟨ p , q ⟩ c'
    r : {a : A} →  isRefl (λ section₁ → _≅S⟨_⟩_ section₁ (ρA a))
    r {a} (b , c) .fst = ρB b
    r {a} (b , c) .snd = subst (λ q → c ≅C⟨ q ⟩ c)
                               (transportRefl (ρA a , ρB b))
                               (ρC c)
    -- cont : (a : A) → contrRelSingl (λ bc → _≅S⟨_⟩_ bc (ρA a))
    cont : (a : A) → ((b , c) : Σ[ b ∈ B a ] C (a , b)) → isContr (Σ[ bc' ∈ (Σ[ b' ∈ B a ] C (a , b')) ] ((b , c) ≅S⟨ ρA a ⟩ bc'))
    cont a (b , c) = center , k
      where
        center : Σ[ bc' ∈ (Σ[ b' ∈ B a ] C (a , b')) ] ((b , c) ≅S⟨ ρA a ⟩ bc')
        center = (b , c) , r (b , c)
        conSingl : contrRelSingl (λ _ bc' → (b , c) ≅S⟨ ρA a ⟩ bc')
        conSingl = isUnivalent→contrRelSingl _ {!!}
        h : (b' : B a) (c' : C (a , b')) (q : ((b , c) ≅S⟨ ρA a ⟩ (b' , c'))) → center ≡ ((b' , c') , q)
        h b' c' q = J (λ w _ → center ≡ w)
                      refl
                      (isContr→isProp (conSingl (b' , c')) center ((b' , c') , q))
        k : (w : Σ[ bc' ∈ (Σ[ b' ∈ B a ] C (a , b')) ] ((b , c) ≅S⟨ ρA a ⟩ bc')) → center ≡ w
        k ((b' , c') , q) = h b' c' q




