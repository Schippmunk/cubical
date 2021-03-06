{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.Relation.Binary.Base where

open import Cubical.Core.Everything

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.HLevels
open import Cubical.Data.Sigma
open import Cubical.HITs.SetQuotients.Base
open import Cubical.HITs.PropositionalTruncation.Base
open import Cubical.Foundations.Equiv.Fiberwise
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.Isomorphism

private
  variable
    ℓA ℓA' ℓ ℓ' ℓ≅A ℓ≅A' ℓB : Level

-- Rel : ∀ {ℓ} (A B : Type ℓ) (ℓ' : Level) → Type (ℓ-max ℓ (ℓ-suc ℓ'))
-- Rel A B ℓ' = A → B → Type ℓ'

Rel : (A : Type ℓA) (B : Type ℓB) (ℓ : Level) → Type (ℓ-max (ℓ-suc ℓ) (ℓ-max ℓA ℓB))
Rel A B ℓ = A → B → Type ℓ

PropRel : ∀ {ℓ} (A B : Type ℓ) (ℓ' : Level) → Type (ℓ-max ℓ (ℓ-suc ℓ'))
PropRel A B ℓ' = Σ[ R ∈ Rel A B ℓ' ] ∀ a b → isProp (R a b)

idPropRel : ∀ {ℓ} (A : Type ℓ) → PropRel A A ℓ
idPropRel A .fst a a' = ∥ a ≡ a' ∥
idPropRel A .snd _ _ = squash

invPropRel : ∀ {ℓ ℓ'} {A B : Type ℓ}
  → PropRel A B ℓ' → PropRel B A ℓ'
invPropRel R .fst b a = R .fst a b
invPropRel R .snd b a = R .snd a b

compPropRel : ∀ {ℓ ℓ' ℓ''} {A B C : Type ℓ}
  → PropRel A B ℓ' → PropRel B C ℓ'' → PropRel A C (ℓ-max ℓ (ℓ-max ℓ' ℓ''))
compPropRel R S .fst a c = ∥ Σ[ b ∈ _ ] (R .fst a b × S .fst b c) ∥
compPropRel R S .snd _ _ = squash

graphRel : ∀ {ℓ} {A B : Type ℓ} → (A → B) → Rel A B ℓ
graphRel f a b = f a ≡ b


module _ {ℓ ℓ' : Level} {A : Type ℓ} (_R_ : Rel A A ℓ') where
  -- R is reflexive
  isRefl : Type (ℓ-max ℓ ℓ')
  isRefl = (a : A) → a R a

  -- R is symmetric
  isSym : Type (ℓ-max ℓ ℓ')
  isSym = (a b : A) → a R b → b R a

  -- R is transitive
  isTrans : Type (ℓ-max ℓ ℓ')
  isTrans = (a b c : A)  → a R b → b R c → a R c

  record isEquivRel : Type (ℓ-max ℓ ℓ') where
    constructor equivRel
    field
      reflexive : isRefl
      symmetric : isSym
      transitive : isTrans

  isPropValued : Type (ℓ-max ℓ ℓ')
  isPropValued = (a b : A) → isProp (a R b)

  isEffective : Type (ℓ-max ℓ ℓ')
  isEffective =
    (a b : A) → isEquiv (eq/ {R = _R_} a b)

  -- the total space corresponding to the binary relation w.r.t. a
  relSinglAt : (a : A) → Type (ℓ-max ℓ ℓ')
  relSinglAt a = Σ[ a' ∈ A ] (a R a')

  -- the statement that the total space is contractible at any a
  contrRelSingl : Type (ℓ-max ℓ ℓ')
  contrRelSingl = (a : A) → isContr (relSinglAt a)

  -- assume a reflexive binary relation
  module _ (ρ : isRefl) where
    -- identity is the least reflexive relation
    ≡→R : {a a' : A} → a ≡ a' → a R a'
    -- ≡→R {a} {a'} p = subst (λ z → a R z) p (ρ a)
    ≡→R {a} {a'} p = J (λ z q → a R z) (ρ a) p

    -- what it means for a reflexive binary relation to be univalent
    isUnivalent : Type (ℓ-max ℓ ℓ')
    isUnivalent = (a a' : A) → isEquiv (≡→R {a} {a'})

    -- helpers for contrRelSingl→isUnivalent
    private
      module _ (a : A) where
        -- wrapper for ≡→R
        f = λ (a' : A) (p : a ≡ a') → ≡→R {a} {a'} p

        -- the corresponding total map that univalence
        -- of R will be reduced to
        totf : singl a → Σ[ a' ∈ A ] (a R a')
        totf (a' , p) = (a' , f a' p)

    -- if the total space corresponding to R is contractible
    -- then R is univalent
    -- because the singleton at a is also contractible
    contrRelSingl→isUnivalent : contrRelSingl → isUnivalent
    contrRelSingl→isUnivalent c a = q
      where
        abstract
          q = fiberEquiv (λ a' → a ≡ a')
                   (λ a' → a R a')
                   (f a)
                   (snd (propBiimpl→Equiv (isContr→isProp (isContrSingl a))
                                           (isContr→isProp (c a))
                                           (totf a)
                                           (λ _ → fst (isContrSingl a))))

    -- converse map. proof idea:
    -- equivalences preserve contractability,
    -- singletons are contractible
    -- and by the univalence assumption the total map is an equivalence
    isUnivalent→contrRelSingl : isUnivalent → contrRelSingl
    isUnivalent→contrRelSingl u a = q
      where
        abstract
          q = isContrRespectEquiv
                               (totf a , totalEquiv (a ≡_)
                                                    (a R_)
                                                    (f a)
                                                    λ a' → u a a')
                               (isContrSingl a)

    isUnivalent' : Type (ℓ-max ℓ ℓ')
    isUnivalent' = (a a' : A) → (a ≡ a') ≃ a R a'

    private
      module _ (e : isUnivalent') (a : A) where
        -- wrapper for ≡→R
        g = λ (a' : A) (p : a ≡ a') → e a a' .fst p

        -- the corresponding total map that univalence
        -- of R will be reduced to
        totg : singl a → Σ[ a' ∈ A ] (a R a')
        totg (a' , p) = (a' , g a' p)

      isUnivalent'→contrRelSingl : isUnivalent' → contrRelSingl
      isUnivalent'→contrRelSingl u a = q
        where
          abstract
            q = isContrRespectEquiv
                                 (totg u a , totalEquiv (a ≡_) (a R_) (g u a) λ a' → u a a' .snd)
                                 (isContrSingl a)


    isUnivalent'→isUnivalent : isUnivalent' → isUnivalent
    isUnivalent'→isUnivalent u = contrRelSingl→isUnivalent (isUnivalent'→contrRelSingl u)

    isUnivalent→isUnivalent' : isUnivalent → isUnivalent'
    isUnivalent→isUnivalent' u a a' = ≡→R {a} {a'} , u a a'


record RelIso {A : Type ℓA} (_≅_ : Rel A A ℓ≅A)
              {A' : Type ℓA'} (_≅'_ : Rel A' A' ℓ≅A') : Type (ℓ-max (ℓ-max ℓA ℓA') (ℓ-max ℓ≅A ℓ≅A')) where
  constructor reliso
  field
    fun : A → A'
    inv : A' → A
    rightInv : (a' : A') → fun (inv a') ≅' a'
    leftInv : (a : A) → inv (fun a) ≅ a

RelIso→Iso : {A : Type ℓA} {A' : Type ℓA'}
             (_≅_ : Rel A A ℓ≅A) (_≅'_ : Rel A' A' ℓ≅A')
             {ρ : isRefl _≅_} {ρ' : isRefl _≅'_}
             (uni : isUnivalent _≅_ ρ) (uni' : isUnivalent _≅'_ ρ')
             (f : RelIso _≅_ _≅'_)
             → Iso A A'
Iso.fun (RelIso→Iso _ _ _ _ f) = RelIso.fun f
Iso.inv (RelIso→Iso _ _ _ _ f) = RelIso.inv f
Iso.rightInv (RelIso→Iso _ _≅'_ {ρ' = ρ'} _ uni' f) a'
  = invEquiv (≡→R _≅'_ ρ' , uni' (RelIso.fun f (RelIso.inv f a')) a') .fst (RelIso.rightInv f a')
Iso.leftInv (RelIso→Iso _≅_ _ {ρ = ρ} uni _ f) a
  = invEquiv (≡→R _≅_ ρ , uni (RelIso.inv f (RelIso.fun f a)) a) .fst (RelIso.leftInv f a)


EquivRel : ∀ {ℓ} (A : Type ℓ) (ℓ' : Level) → Type (ℓ-max ℓ (ℓ-suc ℓ'))
EquivRel A ℓ' = Σ[ R ∈ Rel A A ℓ' ] isEquivRel R

EquivPropRel : ∀ {ℓ} (A : Type ℓ) (ℓ' : Level) → Type (ℓ-max ℓ (ℓ-suc ℓ'))
EquivPropRel A ℓ' = Σ[ R ∈ PropRel A A ℓ' ] isEquivRel (R .fst)
