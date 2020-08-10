{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.DStructures.Structures.Strict2Group where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Functions.FunExtEquiv

open import Cubical.Homotopy.Base

open import Cubical.Data.Sigma

open import Cubical.Relation.Binary
open BinaryRelation

open import Cubical.Structures.Group
open import Cubical.Structures.LeftAction

open import Cubical.DStructures.Base
open import Cubical.DStructures.Meta.Properties
open import Cubical.DStructures.Structures.Constant
open import Cubical.DStructures.Meta.Combine
open import Cubical.DStructures.Structures.Type
open import Cubical.DStructures.Structures.Group

module _ {ℓ ℓ' : Level} where
  private
    ℓℓ' = ℓ-max ℓ ℓ'

  -- type of composition operations on the reflexive graph 𝒢
  record Comp (𝒢 : ReflGraph ℓ ℓ') : Type ℓℓ' where

    private
      G₁ = snd (fst (fst (fst (fst 𝒢))))
      G₀ = fst (fst (fst (fst (fst 𝒢))))
      σ = snd (snd (fst (fst (fst 𝒢))))
      τ = snd (fst 𝒢)
      ι = fst (snd (fst (fst (fst 𝒢))))
      s = GroupHom.fun σ
      t = GroupHom.fun τ
      𝒾 = GroupHom.fun ι
      split-τ = snd 𝒢
      split-σ = snd (fst (fst 𝒢))

      σι-≡-fun = λ (g : ⟨ G₀ ⟩) → funExt⁻ (cong GroupHom.fun split-σ) g
      τι-≡-fun = λ (g : ⟨ G₀ ⟩) → funExt⁻ (cong GroupHom.fun split-τ) g

      open GroupNotation₁ G₁
      open GroupNotation₀ G₀
      open GroupHom

      isComposable : (g f : ⟨ G₁ ⟩) → Type ℓ
      isComposable g f = s g ≡ t f

      +-c : (g f : ⟨ G₁ ⟩) (c : isComposable g f)
            (g' f' : ⟨ G₁ ⟩) (c' : isComposable g' f')
            → isComposable (g +₁ g') (f +₁ f')
      +-c g f c g' f' c' = σ .isHom g g'
                           ∙∙ cong (_+₀ s g') c
                           ∙∙ cong (t f +₀_) c'
                           ∙ sym (τ .isHom f f')

    field
      ∘ : (g f : ⟨ G₁ ⟩) → (isComposable g f) → ⟨ G₁ ⟩

    syntax ∘ g f p = g ∘⟨ p ⟩ f

    field
      σ-∘ : (g f : ⟨ G₁ ⟩) (c : isComposable g f) → s (g ∘⟨ c ⟩ f) ≡ s f
      τ-∘ : (g f : ⟨ G₁ ⟩) (c : isComposable g f) → t (g ∘⟨ c ⟩ f) ≡ t g
      isHom-∘ : (g f : ⟨ G₁ ⟩) (c : isComposable g f)
                (g' f' : ⟨ G₁ ⟩) (c' : isComposable g' f')
                → (g +₁ g') ∘⟨ +-c g f c g' f' c' ⟩ (f +₁ f') ≡ (g ∘⟨ c ⟩ f) +₁ (g' ∘⟨ c' ⟩ f')
      assoc-∘ : (h g f : ⟨ G₁ ⟩) (c : isComposable h g) (c' : isComposable g f)
                → h ∘⟨ c ∙ sym (τ-∘ g f c') ⟩ (g ∘⟨ c' ⟩ f) ≡ (h ∘⟨ c ⟩ g) ∘⟨ σ-∘ h g c ∙ c' ⟩ f
      lid-∘ : (f : ⟨ G₁ ⟩) → 𝒾 (t f) ∘⟨ σι-≡-fun (t f) ⟩ f ≡ f
      rid-∘ : (g : ⟨ G₁ ⟩) → g ∘⟨ sym (τι-≡-fun (s g)) ⟩ 𝒾 (s g) ≡ g

  isPropComp : (𝒢 : ReflGraph ℓ ℓ') → isProp (Comp 𝒢)
  isPropComp 𝒢 𝒞 𝒞' = {!!}
