-- Displayed SIP
{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.DStructures.Base where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.Equiv.Properties
open import Cubical.Foundations.Function
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Univalence
open import Cubical.Foundations.Path
open import Cubical.Foundations.SIP
open import Cubical.Data.Sigma

open import Cubical.Relation.Binary
open BinaryRelation

private
  variable
    ℓ ℓ' ℓ'' ℓ₁ ℓ₁' ℓ₁'' ℓ₂ ℓA ℓ≅A ℓB ℓ≅B ℓC ℓ≅C ℓ≅ᴰ : Level

{- Stuff to do:
 * get URGStr from univalent bi-category
 * (Bonus: (A : Type ℓ) → isContr (URGStr A ℓ))
 * functoriality for free for e : (a : A) → B a → B' a
 * standard notion of structure
-}
-- a univalent reflexive graph structure on a type
record URGStr (A : Type ℓA) (ℓ≅A : Level) : Type (ℓ-max ℓA (ℓ-suc ℓ≅A)) where
  no-eta-equality
  constructor urgstr
  field
    _≅_ : Rel A A ℓ≅A
    ρ : isRefl _≅_
    uni : isUnivalent _≅_ ρ

-- wrapper to create instances of URGStr
make-𝒮 : {A : Type ℓA} {_≅_ : Rel A A ℓ≅A}
         (ρ : isRefl _≅_) (contrTotal : contrTotalSpace _≅_)
         → URGStr A ℓ≅A
make-𝒮 {_≅_ = _≅_} _ _ .URGStr._≅_ = _≅_
make-𝒮 ρ _ .URGStr.ρ = ρ
make-𝒮 {_≅_ = _≅_} ρ contrTotal .URGStr.uni = contrTotalSpace→isUnivalent _≅_ ρ contrTotal

-- a displayed univalent reflexive graph structure over a URGStr on a type
record URGStrᴰ {A : Type ℓA} (𝒮-A : URGStr A ℓ≅A)
               (B : A → Type ℓB) (ℓ≅ᴰ : Level) : Type (ℓ-max (ℓ-max (ℓ-max ℓA ℓB) ℓ≅A) (ℓ-suc ℓ≅ᴰ)) where
  no-eta-equality
  constructor urgstrᴰ
  open URGStr 𝒮-A

  field
    _≅ᴰ⟨_⟩_ : {a a' : A} → B a → a ≅ a' → B a' → Type ℓ≅ᴰ
    ρᴰ : {a : A} → isRefl _≅ᴰ⟨ ρ a ⟩_
    uniᴰ : {a : A} → isUnivalent _≅ᴰ⟨ ρ a ⟩_ ρᴰ

open URGStrᴰ
-- wrapper to create instances of URGStrᴰ
make-𝒮ᴰ : {A : Type ℓA} {𝒮-A : URGStr A ℓ≅A}
          {B : A → Type ℓB}
          (_≅ᴰ⟨_⟩_ : {a a' : A} → B a → URGStr._≅_ 𝒮-A a a' → B a' → Type ℓ≅ᴰ)
          (ρᴰ : {a : A} → isRefl _≅ᴰ⟨ URGStr.ρ 𝒮-A a ⟩_)
          (contrTotal : (a : A) → contrTotalSpace _≅ᴰ⟨ URGStr.ρ 𝒮-A a ⟩_)
          → URGStrᴰ 𝒮-A B ℓ≅ᴰ
make-𝒮ᴰ {A = A} {𝒮-A = 𝒮-A} _≅ᴰ⟨_⟩_ ρᴰ contrTotal ._≅ᴰ⟨_⟩_ = _≅ᴰ⟨_⟩_
make-𝒮ᴰ {A = A} {𝒮-A = 𝒮-A} _≅ᴰ⟨_⟩_ ρᴰ contrTotal .ρᴰ = ρᴰ
make-𝒮ᴰ {A = A} {𝒮-A = 𝒮-A} _≅ᴰ⟨_⟩_ ρᴰ contrTotal .uniᴰ {a} b b' = contrTotalSpace→isUnivalent (_≅ᴰ⟨ URGStr.ρ 𝒮-A a ⟩_) (ρᴰ {a}) (contrTotal a) b b'

-- abbreviation to obtain contractibility of total space
𝒮→cTS : {A : Type ℓA} (StrA : URGStr A ℓ≅A) → contrTotalSpace (URGStr._≅_ StrA)
𝒮→cTS StrA = isUnivalent→contrTotalSpace _≅_ ρ uni
  where open URGStr StrA
