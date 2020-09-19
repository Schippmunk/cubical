{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.DStructures.Structures.Universe where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Univalence
open import Cubical.Data.Sigma

open import Cubical.DStructures.Base
open import Cubical.DStructures.Meta.Properties

private
  variable
    ℓ ℓ' ℓ'' ℓ₁ ℓ₁' ℓ₁'' ℓ₂ ℓA ℓ≅A ℓB ℓ≅B ℓ≅ᴰ : Level

-- Universes and equivalences form a URGStr
𝒮-universe : URGStr (Type ℓ) ℓ
𝒮-universe
  = make-𝒮 {_≅_ = _≃_}
            idEquiv
            λ A → isContrRespectEquiv (Σ-cong-equiv-snd (λ A' → isoToEquiv (iso invEquiv
                                                                                  invEquiv
                                                                                  (λ e → equivEq (invEquiv (invEquiv e)) e (funExt (λ x → refl)))
                                                                                  λ e → equivEq (invEquiv (invEquiv e)) e (funExt (λ x → refl)))))
                                       (EquivContr A)

𝒮ᴰ-pointed : {ℓ : Level} → URGStrᴰ (𝒮-universe {ℓ}) (λ A → A) ℓ
𝒮ᴰ-pointed {ℓ} =
  make-𝒮ᴰ (λ a e b → equivFun e a ≡ b)
          (λ _ → refl)
          p
          where
            p : (A : Type ℓ) (a : A) → isContr (Σ[ b ∈ A ] a ≡ b)
            p _ a = isContrSingl a

𝒮-pointed : {ℓ : Level} → URGStr (Σ[ A ∈ Type ℓ ] A) ℓ
𝒮-pointed = ∫⟨ 𝒮-universe ⟩ 𝒮ᴰ-pointed

