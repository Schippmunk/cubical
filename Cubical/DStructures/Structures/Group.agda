{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.DStructures.Structures.Group where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Functions.FunExtEquiv

open import Cubical.Homotopy.Base

open import Cubical.Data.Sigma

open import Cubical.Relation.Binary


open import Cubical.Structures.Group
open import Cubical.Structures.LeftAction

open import Cubical.DStructures.Base
open import Cubical.DStructures.Meta.Properties
open import Cubical.DStructures.Structures.Constant
open import Cubical.DStructures.Meta.Combine
open import Cubical.DStructures.Structures.Type

private
  variable
    ℓ ℓ' : Level

open URGStr

-- groups with group isomorphisms structure
𝒮-group : (ℓ : Level) → URGStr (Group {ℓ}) ℓ
𝒮-group ℓ ._≅_ = GroupEquiv
𝒮-group ℓ .ρ = idGroupEquiv
𝒮-group ℓ .uni = isUnivalent'→isUnivalent GroupEquiv
                                          idGroupEquiv
                                          λ G H → invEquiv (GroupPath G H)

module _ {ℓ ℓ' : Level} where
  module GroupDisplayHelper {G : Group {ℓ}} {H : Group {ℓ'}} where
    BContr : (f : GroupHom H G) → isContr (Σ[ f' ∈ GroupHom H G ] (GroupHom.fun f ∼ GroupHom.fun f'))
    BContr f =  isOfHLevelRespectEquiv 0 (Σ-cong-equiv-snd (λ f' → isoToEquiv (invIso (GroupMorphismExtIso f f')))) (isContrSingl f)

    module Coherence {G' : Group {ℓ}} {H' : Group {ℓ'}}
                     (eG : GroupEquiv G G') (eH : GroupEquiv H H') where
           tr-eG = GroupEquiv.eq eG .fst
           tr-eH = GroupEquiv.eq eH .fst
           _* = GroupHom.fun

           FCondition : (f : GroupHom G H) (f' : GroupHom G' H')
                          → Type (ℓ-max ℓ ℓ')
           FCondition f f' = (g : ⟨ G ⟩) → tr-eH ((f *) g) ≡ (f' *) (tr-eG g)

           BCondition : (f : GroupHom H G) (f' : GroupHom H' G')
                         → Type (ℓ-max ℓ ℓ')
           BCondition f f' = (h : ⟨ H ⟩) → tr-eG ((f *) h) ≡ (f' *) (tr-eH h)

open GroupDisplayHelper

module _ (ℓ ℓ' : Level) where
  -- notation
  -- G - group
  -- G² - pair of groups
  -- F - morphism forth
  -- B - morphism back
  -- SecRet - two morphisms that are a section retraction pair

  G² = Group {ℓ} × Group {ℓ'}
  G²F = Σ[ (G , H) ∈ G² ] GroupHom G H
  G²B = Σ[ (G , H) ∈ G² ] GroupHom H G
  G²FB = Σ[ (G , H) ∈ G² ] GroupHom G H × GroupHom H G

  -- type of Split epimorphisms
  SplitEpi = Σ[ ((G , H) , f , b) ∈ G²FB ] isGroupSplitEpi f b

  SplitEpiB = Σ[ (((G , H) , f , b) , isRet) ∈ SplitEpi ] GroupHom H G

  -- type of internal reflexive graphs in the category of groups
  ReflGraph = Σ[ ((((G , H) , f , b) , isRet) , b') ∈ SplitEpiB ] isGroupSplitEpi f b'

  -- Group morphisms displayed over pairs of groups
  𝒮ᴰ-G²\F : URGStrᴰ (𝒮-group ℓ ×𝒮 𝒮-group ℓ')
                    (λ (G , H) → GroupHom G H)
                    (ℓ-max ℓ ℓ')
  𝒮ᴰ-G²\F =
    make-𝒮ᴰ (λ {(G , _)} f (eG , eH) f'
                   → Coherence.FCondition eG eH f f')
                (λ _ _ → refl)
                λ (G , H) f → isOfHLevelRespectEquiv 0
                                                     -- Σ[ f' ∈ GroupHom G H ] (f ≡ f')
                                                     --  ≃ Σ[ (grouphom f' _) ∈ GroupHom G H ] ((g : ⟨ G ⟩) → GroupHom.fun f g ≡ f' g)
                                                     (Σ-cong-equiv-snd (λ f' → isoToEquiv (invIso (GroupMorphismExtIso f f'))))
                                                     (isContrSingl f)


  -- URG structure on type of two groups with a group morphism
  𝒮-G²F : URGStr G²F (ℓ-max ℓ ℓ')
  𝒮-G²F = ∫⟨ 𝒮-group ℓ ×𝒮 𝒮-group ℓ' ⟩ 𝒮ᴰ-G²\F

  -- Same as 𝒮-G²F but with the morphism going the other way
  𝒮ᴰ-G²\B : URGStrᴰ (𝒮-group ℓ ×𝒮 𝒮-group ℓ')
                             (λ (G , H) → GroupHom H G)
                             (ℓ-max ℓ ℓ')
  𝒮ᴰ-G²\B =
    make-𝒮ᴰ (λ {(_ , H)} f (eG , eH) f'
                  → Coherence.BCondition eG eH f f')
                (λ _ _ → refl)
                λ _ f → BContr f

  -- Type of two groups with a group morphism going back
  𝒮-G²B : URGStr G²B (ℓ-max ℓ ℓ')
  𝒮-G²B = ∫⟨ 𝒮-group ℓ ×𝒮 𝒮-group ℓ' ⟩ 𝒮ᴰ-G²\B


  -- Morphisms going forth and back displayed over pairs of groups
  𝒮ᴰ-G²\FB : URGStrᴰ (𝒮-group ℓ ×𝒮 𝒮-group ℓ')
                   (λ (G , H) → GroupHom G H × GroupHom H G)
                   (ℓ-max ℓ ℓ')
  𝒮ᴰ-G²\FB = combine-𝒮ᴰ 𝒮ᴰ-G²\F 𝒮ᴰ-G²\B

  -- URG structure on type of pairs of groups with morphisms going forth and back
  𝒮-G²FB : URGStr G²FB (ℓ-max ℓ ℓ')
  𝒮-G²FB = ∫⟨ 𝒮-group ℓ ×𝒮 𝒮-group ℓ' ⟩ 𝒮ᴰ-G²\FB

  -- split epimorphisms displayed over pairs of groups
  𝒮ᴰ-SplitEpi : URGStrᴰ 𝒮-G²FB
                        (λ ((G , H) , (f , g)) → isGroupSplitEpi f g)
                        ℓ-zero
  𝒮ᴰ-SplitEpi =
    Subtype→Sub-𝒮ᴰ (λ ((G , H) , (f , g)) → isGroupSplitEpi f g , isPropIsGroupHomRet f g)
                   𝒮-G²FB

  -- URG structure on type of split epimorphisms
  𝒮-SplitEpi : URGStr SplitEpi (ℓ-max ℓ ℓ')
  𝒮-SplitEpi = ∫⟨ 𝒮-G²FB ⟩ 𝒮ᴰ-SplitEpi

  -- section retraction pair + morphism back displayed over SG²Secre
  𝒮ᴰ-G²FBSplit\B' : URGStrᴰ 𝒮-SplitEpi
                           (λ (((G , H) , _) , _) → GroupHom H G)
                           (ℓ-max ℓ ℓ')
  𝒮ᴰ-G²FBSplit\B'
    = make-𝒮ᴰ (λ {(((G , H) , _) , _)} f (((eG , eH) , _) , _) f'
                  → Coherence.BCondition eG eH f f')
              (λ _ _ → refl)
               λ (((G , H) , x) , isRet) f → BContr f

  𝒮ᴰ-G²FBSplit\B : URGStrᴰ 𝒮-SplitEpi
                           (λ (((G , H) , _) , _) → GroupHom H G)
                           (ℓ-max ℓ ℓ')
  𝒮ᴰ-G²FBSplit\B =
    VerticalLift2-𝒮ᴰ (𝒮-group ℓ ×𝒮 𝒮-group ℓ')
                     𝒮ᴰ-G²\B
                     𝒮ᴰ-G²\FB
                     𝒮ᴰ-SplitEpi

  𝒮-SplitEpiB : URGStr SplitEpiB (ℓ-max ℓ ℓ')
  𝒮-SplitEpiB = ∫⟨ 𝒮-SplitEpi ⟩ 𝒮ᴰ-G²FBSplit\B


  𝒮ᴰ-ReflGraph : URGStrᴰ 𝒮-SplitEpiB
                        (λ ((((G , H) , f , b) , isRet) , b')
                          → isGroupSplitEpi f b')
                        ℓ-zero
  𝒮ᴰ-ReflGraph = Subtype→Sub-𝒮ᴰ (λ ((((G , H) , f , b) , isRet) , b')
                                   → isGroupSplitEpi f b' , isPropIsGroupHomRet f b')
                                𝒮-SplitEpiB

  𝒮-ReflGraph : URGStr ReflGraph (ℓ-max ℓ ℓ')
  𝒮-ReflGraph = ∫⟨ 𝒮-SplitEpiB ⟩ 𝒮ᴰ-ReflGraph

module SplitEpiNotation {G₀ : Group {ℓ}} {G₁ : Group {ℓ'}}
                        (ι : GroupHom G₀ G₁) (σ : GroupHom G₁ G₀)
                        (split : isGroupSplitEpi ι σ) where
  open GroupNotation₀ G₀
  open GroupNotation₁ G₁
  s = GroupHom.fun σ
  -- i is reserved for an interval variable (i : I) so we use 𝒾 instead
  𝒾 = GroupHom.fun ι
  -i = λ (x : ⟨ G₀ ⟩) → -₁ (𝒾 x)
  s- = λ (x : ⟨ G₁ ⟩) → s (-₁ x)
  si = λ (x : ⟨ G₀ ⟩) → s (𝒾 x)
  is = λ (x : ⟨ G₁ ⟩) → 𝒾 (s x)
  -si = λ (x : ⟨ G₀ ⟩) → -₀ (si x)
  -is = λ (x : ⟨ G₁ ⟩) → -₁ (is x)
  si- = λ (x : ⟨ G₀ ⟩) → si (-₀ x)
  is- = λ (x : ⟨ G₁ ⟩) → is (-₁ x)
  s-i = λ (x : ⟨ G₀ ⟩) → s (-₁ (𝒾 x))
  isi = λ (x : ⟨ G₀ ⟩) → 𝒾 (s (𝒾 x))
