{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.DStructures.Structures.Action where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Functions.FunExtEquiv

open import Cubical.Data.Sigma

open import Cubical.Algebra.Group
open import Cubical.Structures.LeftAction

open import Cubical.DStructures.Base
open import Cubical.DStructures.Meta.Properties

open import Cubical.DStructures.Structures.Constant
open import Cubical.DStructures.Structures.Type
open import Cubical.DStructures.Structures.Group

private
  module _ {ℓ ℓ' : Level} where
    Las : ((G , H) : Group {ℓ} × Group {ℓ'}) → Type (ℓ-max ℓ ℓ')
    Las (G , H) = LeftActionStructure ⟨ G ⟩ ⟨ H ⟩

module _ (ℓ ℓ' : Level) where
  G²Las = Σ[ GH ∈ G² ℓ ℓ' ] Las GH
  GGLas = Σ[ G ∈ Group {ℓ} ] Σ[ H ∈ Group {ℓ'} ] Las (G , H)
  Action = Σ[ ((G , H) , _α_) ∈ G²Las ] (IsGroupAction G H _α_)
  G²LasAct = Σ[ (G , H) ∈ G² ℓ ℓ' ] Σ[ α ∈ Las (G , H) ] IsGroupAction G H α
  GGLasAct = Σ[ G ∈ Group {ℓ} ] Σ[ H ∈ Group {ℓ'} ] Σ[ α ∈ Las (G , H) ] IsGroupAction G H α

  IsoAction : Iso Action GGLasAct
  IsoAction = compIso Σ-assoc-Iso Σ-assoc-Iso


  -- two groups with an action structure, i.e. a map ⟨ G ⟩ → ⟨ H ⟩ → ⟨ H ⟩
  𝒮ᴰ-G²\Las : URGStrᴰ (𝒮-group ℓ ×𝒮 𝒮-group ℓ')
                      (λ GH → Las GH)
                      (ℓ-max ℓ ℓ')
  𝒮ᴰ-G²\Las =
    make-𝒮ᴰ (λ {(G , H)} _α_ (eG , eH) _β_
                   → (g : ⟨ G ⟩) (h : ⟨ H ⟩)
                     → GroupEquiv.eq eH .fst (g α h) ≡ (GroupEquiv.eq eG .fst g) β (GroupEquiv.eq eH .fst h))
                (λ _ _ _ → refl)
                λ (G , H) _α_ → isContrRespectEquiv
                                                       -- (Σ[ _β_ ∈ Las (G , H) ] (_α_ ≡ _β_)
                                                       (Σ-cong-equiv-snd (λ _β_ → invEquiv funExt₂Equiv))
                                                       (isContrSingl _α_)

  𝒮-G²Las : URGStr G²Las (ℓ-max ℓ ℓ')
  𝒮-G²Las = ∫⟨ 𝒮-group ℓ ×𝒮 𝒮-group ℓ' ⟩ 𝒮ᴰ-G²\Las

  open ActionΣTheory

  𝒮ᴰ-G²Las\Action : URGStrᴰ 𝒮-G²Las
                     (λ ((G , H) , _α_) → IsGroupAction G H _α_)
                     ℓ-zero
  𝒮ᴰ-G²Las\Action = Subtype→Sub-𝒮ᴰ (λ ((G , H) , _α_) → IsGroupAction G H _α_ , isPropIsGroupAction G H _α_)
                             𝒮-G²Las

  𝒮-G²LasAction : URGStr Action (ℓ-max ℓ ℓ')
  𝒮-G²LasAction = ∫⟨ 𝒮-G²Las ⟩ 𝒮ᴰ-G²Las\Action

  𝒮-Action = 𝒮-G²LasAction

  𝒮ᴰ-G\GLasAction : URGStrᴰ (𝒮-group ℓ)
                            (λ G → Σ[ H ∈ Group {ℓ'} ] Σ[ α ∈ Las (G , H) ] IsGroupAction G H α)
                            (ℓ-max ℓ ℓ')
  𝒮ᴰ-G\GLasAction =
    splitTotal-𝒮ᴰ (𝒮-group ℓ)
                  (𝒮ᴰ-const (𝒮-group ℓ) (𝒮-group ℓ'))
                  (splitTotal-𝒮ᴰ (𝒮-group ℓ ×𝒮 𝒮-group ℓ')
                                 𝒮ᴰ-G²\Las
                                 𝒮ᴰ-G²Las\Action)
