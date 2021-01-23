
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
    ℓA ℓA' ℓB ℓB' : Level

record UARel (A : Type ℓA) (ℓ≅A : Level) : Type (ℓ-max ℓA (ℓ-suc ℓ≅A)) where
  no-eta-equality
  constructor uarel
  field
    _≅_ : A → A → Type ℓ≅A
    ua : (a a' : A) → (a ≅ a') ≃ (a ≡ a')
  ρ : (a : A) → a ≅ a
  ρ a = invEq (ua a a) refl

open BinaryRelation

-- another constructor for UARel using contractibility of relational singletons
make-𝒮 : {A : Type ℓA} {ℓ≅A : Level} {_≅_ : A → A → Type ℓ≅A}
          (ρ : isRefl _≅_) (contrTotal : contrRelSingl _≅_) → UARel A ℓ≅A
UARel._≅_ (make-𝒮 {_≅_ = _≅_} _ _) = _≅_
UARel.ua (make-𝒮 {_≅_ = _≅_} ρ c) = contrRelSingl→isUnivalent _≅_ ρ c

record DUARel {A : Type ℓA} {ℓ≅A : Level} {𝒮-A : UARel A ℓ≅A}
              (B : A → Type ℓB) (ℓ≅B : Level) : Type (ℓ-max (ℓ-max ℓA ℓB) (ℓ-max ℓ≅A (ℓ-suc ℓ≅B))) where
  no-eta-equality
  constructor duarel
  open UARel 𝒮-A

  field
    _≅ᴰ⟨_⟩_ : {a a' : A} → B a → a ≅ a' → B a' → Type ℓ≅B
    uaᴰ : {a : A} → (b b' : B a) → (b ≅ᴰ⟨ ρ a ⟩ b') ≃ (b ≡ b')
  ρᴰ : {a : A} → (b : B a) → b ≅ᴰ⟨ ρ a ⟩ b
  ρᴰ {a} b = invEq (uaᴰ b b) refl

total : {A : Type ℓA} {ℓ≅A : Level} {𝒮-A : UARel A ℓ≅A}
        {B : A → Type ℓB} {ℓ≅B : Level}
        (𝒮ᴰ-B : DUARel B ℓ≅B)
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

--isUnivalent→contrRelSingl
{-
-- Base

record URel (A : Type ℓA) (ℓ≅A : Level) : Type (ℓ-max ℓA (ℓ-suc ℓ≅A)) where
  no-eta-equality
  constructor urel
  field
    _≅_ : Rel A A ℓ≅A
    u : {a a' : A} → (a ≅ a') → (a ≡ a')

record DURel {A : Type ℓA} {ℓ≅A : Level} (RA : URel A ℓ≅A)
              (B : A → Type ℓB) (ℓ≅B : Level) : Type (ℓ-max (ℓ-max ℓA ℓB) (ℓ-suc ℓ≅B)) where
  no-eta-equality
  open URel RA

  field
    -- HERE a and a' should be related!
    _D≅_ : {a a' : A} → Rel (B a) (B a') ℓ≅B
    -- _D≅_ : {a a' : A} → (p : a ≅ a') →  Rel (B a) (B a') ℓ≅B
    Du : {a : A} → {b b' : B a} → b D≅ b' → b ≡ b'

-- Total Spaces

∫ : {ℓA  ℓB : Level} {A : Type ℓA} {ℓ≅A : Level} {RA : URel A ℓ≅A}
    {B : A → Type ℓB} {ℓ≅B : Level}
    (RB : DURel RA B ℓ≅B)
    → URel (Σ A B) (ℓ-max ℓ≅A ℓ≅B)
URel._≅_ (∫ {RA = RA} RB) (a , b) (a' , b') = a ≅ a' × b D≅ b'
  where
    open URel RA
    open DURel RB
URel.u (∫ {A = A} {RA = RA} {B = B} RB) (pa , pb) = ΣPathP (u pa , duaB pa pb)
  where
    open URel RA
    open DURel RB

    duaB : ∀{a a'} {b : B a} {b' : B a'}
           → (ia : a ≅ a') → b D≅ b' → PathP (λ i → B (u ia i)) b b'
    duaB {a = a} ia ib = J T Du (u ia) ib
      where
        T : (a' : A) → a ≡ a' → Type _
        T a' p = {b : B a} {b' : B a'} → b D≅ b' → PathP (λ i → B (p i)) b b'

-- Equivalences

URelIso→Iso : {A : Type ℓA} {ℓ≅A : Level} {RA : URel A ℓ≅A}
               {B : Type ℓB} {ℓ≅B : Level} {RB : URel B ℓ≅B}
               (f : RelIso (URel._≅_ RA) (URel._≅_ RB))
               → Iso A B
URelIso→Iso {RA = RA} {RB = RB} f
  = RelIso→Iso (URel._≅_ RA) (URel._≅_ RB) (URel.u RA) (URel.u RB) f
-}


-- Fiberwise
{-
DURelIso→FiberwiseIso : {A : Type ℓA} {ℓ≅A : Level} {RA : URel A ℓ≅A}
                    {B : A → Type ℓB} {ℓ≅B : Level} {RB : DURel RA B ℓ≅B}
                    {B' : A → Type ℓB'} {ℓ≅B' : Level} {RB' : DURel RA B' ℓ≅B'}
                    (g : (a : A) → RelIso (DURel._D≅_ RB) (DURel._D≅_ RB'))
                    → (a : A) → Iso (B a) (B' a)
DURelIso→FiberwiseIso f = {!!}

DURelIso→TotalIso : {A : Type ℓA} {ℓ≅A : Level} {RA : URel A ℓ≅A}
                    {A' : Type ℓA'} {ℓ≅A' : Level} {RA' : URel A' ℓ≅A'}
                    {B : A → Type ℓB} {ℓ≅B : Level} {RB : DURel RA B ℓ≅B}
                    {B' : A' → Type ℓB'} {ℓ≅B' : Level} {RB' : DURel RA' B' ℓ≅B'}
                    (f : Iso A A')
                    (g : (a : A) → RelIso (DURel._D≅_ RB) {!!})
                    → Iso (Σ A B) (Σ A' B')
DURelIso→TotalIso = {!!}
-}


-- Old stuff / alternatives

{-
-- Pullbacks

_*_ : {A : Type ℓA}
     → {A' : Type ℓA'}
     → (f : A → A')
     → (B' : A' → Type ℓB')
     → (a : A)
     → Type ℓB'
f * B' = B' ∘ f
  where
    open import Cubical.Foundations.Function
                    → Iso (Σ A B) (Σ A (f * B'))
total : {A : Type ℓA} {ℓ≅A : Level} {RA : URel A ℓ≅A}
        {B : A → Type ℓB} {ℓ≅B : Level}
        (RB : DURel B ℓ≅B)
        → URel (Σ A B) (ℓ-max ℓ≅A ℓ≅B)
total {A = A} {ℓ≅A = ℓ≅A} {RA = RA} {B = B} {ℓ≅B = ℓ≅B} RB = {!!}
  -- urel _≅Σ_ uaΣ
  where
    open URel RA
    open DURel RB

    _≅Σ_ : Σ A B → Σ A B → Type (ℓ-max ℓ≅A ℓ≅B)
    (a , b) ≅Σ (a' , b') = a ≅ a' × b D≅ b'

    duaB : ∀{a a'} {b : B a} {b' : B a'}
           → (ia : a ≅ a') → b D≅ b' → PathP (λ i → B (u ia i)) b b'
    duaB {a = a} ia ib = J T Du (u ia) ib
      where
        T : (a' : A) → a ≡ a' → Type _
        T a' p = {b : B a} {b' : B a'} → b D≅ b' → PathP (λ i → B (p i)) b b'

    uaΣ : {r r' : Σ A B} → r ≅Σ r' → r ≡ r'
    uaΣ {(a , b)} {(a' , b')} (p₁ , p₂) = ΣPathP (u p₁ , duaB p₁ p₂)
-}
{-
record UARel1 (A : Type ℓA) (ℓ≅A : Level) : Type (ℓ-max ℓA (ℓ-suc ℓ≅A)) where
  no-eta-equality
  constructor uarel1
  field
    _≅_ : A → A → Type ℓ≅A
    ua : {a a' : A} → (a ≅ a') → (a ≡ a')

record DUARel1a {A : Type ℓA} {ℓ≅A : Level} {𝒮-A : UARel1 A ℓ≅A}
              (B : A → Type ℓB) (ℓ≅B : Level) : Type (ℓ-max (ℓ-max ℓA ℓB) (ℓ-suc ℓ≅B)) where
  no-eta-equality
  open UARel1 𝒮-A

  field
    _≅ᴰ_ : {a a' : A} → B a → B a' → Type ℓ≅B
    uaᴰ : {a : A} → {b b' : B a} → b ≅ᴰ b' → b ≡ b'

total1a : {A : Type ℓA} {ℓ≅A : Level} {𝒮-A : UARel1 A ℓ≅A}
          {B : A → Type ℓB} {ℓ≅B : Level}
          (𝒮ᴰ-B : DUARel1a B ℓ≅B)
          → UARel1 (Σ A B) (ℓ-max ℓ≅A ℓ≅B)
total1a {A = A} {ℓ≅A = ℓ≅A} {𝒮-A = 𝒮-A} {B = B} {ℓ≅B = ℓ≅B} 𝒮ᴰ-B =
  uarel1 _≅Σ_ uaΣ
  where
    open UARel1 𝒮-A
    open DUARel1a 𝒮ᴰ-B
    _≅Σ_ : Σ A B → Σ A B → Type (ℓ-max ℓ≅A ℓ≅B)
    (a , b) ≅Σ (a' , b') = a ≅ a' × b ≅ᴰ b'
    duaB : ∀{a a'} {b : B a} {b' : B a'}
           → (ia : a ≅ a') → b ≅ᴰ b' → PathP (λ i → B (ua ia i)) b b'
    duaB {a = a} ia ib = J T uaᴰ (ua ia) ib
      where
        T : (a' : A) → a ≡ a' → Type _
        T a' p = {b : B a} {b' : B a'} → b ≅ᴰ b' → PathP (λ i → B (p i)) b b'
    uaΣ : {r r' : Σ A B} → r ≅Σ r' → r ≡ r'
    uaΣ {(a , b)} {(a' , b')} (p₁ , p₂) = ΣPathP (ua p₁ , duaB p₁ p₂)
-}
{-
record DUARel1b {A : Type ℓA} {ℓ≅A : Level} {𝒮-A : UARel1 A ℓ≅A}
              (B : A → Type ℓB) (ℓ≅B : Level) : Type (ℓ-max (ℓ-max ℓA ℓB) (ℓ-suc ℓ≅B)) where
  no-eta-equality
  open UARel1 𝒮-A
  field
    _≅ᴰ⟨_⟩_ : {a a' : A} → B a → a ≡ a' → B a' → Type ℓ≅B
    uaᴰ : {a : A} → {b b' : B a} → b ≅ᴰ⟨ refl ⟩ b' → b ≡ b'

total1b : {A : Type ℓA} {ℓ≅A : Level} {𝒮-A : UARel1 A ℓ≅A}
          {B : A → Type ℓB} {ℓ≅B : Level}
          (𝒮ᴰ-B : DUARel1b B ℓ≅B)
          → UARel1 (Σ A B) (ℓ-max ℓ≅A ℓ≅B)
total1b {A = A} {ℓ≅A = ℓ≅A} {𝒮-A = 𝒮-A} {B = B} {ℓ≅B = ℓ≅B} 𝒮ᴰ-B =
  uarel1 _≅Σ_ uaΣ
  where
    open UARel1 𝒮-A
    open DUARel1b 𝒮ᴰ-B
    _≅Σ_ : Σ A B → Σ A B → Type (ℓ-max ℓ≅A ℓ≅B)
    (a , b) ≅Σ (a' , b') =  Σ[ p ∈ a ≅ a' ] (b ≅ᴰ⟨ ua p ⟩ b')
    uaΣ : {a a' : Σ A B} → a ≅Σ a' → a ≡ a'
    uaΣ {(a , b)} {(a' , b')} (p₁ , p₂) = ΣPathP (ua p₁ , {!!})
-}
{-
module Total {A : Type u} {B : A → Type u'} (AR : URel A t) (BR : DURel B t') where
  open URel AR renaming (_≅_ to _≅A_; ua to uaA)
  open DURel BR renaming (_≅_ to _≅B_; ua to uaB)

  duaB : ∀{a a'} {b : B a} {b' : B a'}
       → (ia : a ≅A a') → b ≅B b' → PathP (λ i → B (uaA ia i)) b b'
  duaB {a = a} ia ib = J T uaB (uaA ia) ib
    where
    T : (a' : A) → a ≡ a' → Type _
    T a' p = {b : B a} {b' : B a'} → b ≅B b' → PathP (λ i → B (p i)) b b'

  _≅Σ_ : Σ A B → Σ A B → Type _
  (x , y) ≅Σ (x' , y') = (x ≅A x') × (y ≅B y')

  uaΣ : (p q : Σ A B) → p ≅Σ q → p ≡ q
  uaΣ (x , y) (x' , y') (x≅x' , y≅y') = ΣPathP (uaA x≅x' , duaB x≅x' y≅y')
-}
