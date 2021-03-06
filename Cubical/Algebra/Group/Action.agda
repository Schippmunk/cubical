{-# OPTIONS --cubical --no-import-sorts --safe #-}

module Cubical.Algebra.Group.Action where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Structure
open import Cubical.Algebra.Group.Base
open import Cubical.Algebra.Group.Morphism
open import Cubical.Algebra.Group.Properties
open import Cubical.Algebra.Group.Notation
open import Cubical.Algebra.Group.MorphismProperties
open import Cubical.Structures.LeftAction
open import Cubical.Structures.Axioms
open import Cubical.Structures.Macro
open import Cubical.Structures.Auto
open import Cubical.Data.Sigma

private
  variable
    ℓ ℓ' : Level

record IsGroupAction (G : Group {ℓ = ℓ})
                     (H : Group {ℓ = ℓ'})
                     (_α_ : LeftActionStructure ⟨ G ⟩ ⟨ H ⟩) : Type (ℓ-max ℓ ℓ') where
                     
  constructor isgroupaction

  open GroupNotationG G

  field
    isHom : (g : ⟨ G ⟩) → isGroupHom H H (g α_)
    identity : (h : ⟨ H ⟩) → 0ᴳ α h ≡ h
    assoc : (g g' : ⟨ G ⟩) → (h : ⟨ H ⟩) → (g +ᴳ g') α h ≡ g α (g' α h)

record GroupAction (G : Group {ℓ}) (H : Group {ℓ'}): Type (ℓ-suc (ℓ-max ℓ ℓ')) where

  constructor groupaction

  field
    _α_ : LeftActionStructure ⟨ G ⟩ ⟨ H ⟩
    isGroupAction : IsGroupAction G H _α_

module ActionΣTheory {ℓ ℓ' : Level} where

  module _ (G : Group {ℓ}) (H : Group {ℓ'}) (_α_ : LeftActionStructure ⟨ G ⟩ ⟨ H ⟩) where

    open GroupNotationG G

    IsGroupActionΣ : Type (ℓ-max ℓ ℓ')
    IsGroupActionΣ = ((g : ⟨ G ⟩) → isGroupHom H H (g α_))
                         × ((h : ⟨ H ⟩) → 0ᴳ α h ≡ h)
                         × ((g g' : ⟨ G ⟩) → (h : ⟨ H ⟩) → (g +ᴳ g') α h ≡ g α (g' α h))

    isPropIsGroupActionΣ : isProp IsGroupActionΣ
    isPropIsGroupActionΣ = isPropΣ isPropIsHom λ _ → isPropΣ isPropIdentity λ _ → isPropAssoc
      where
        isPropIsHom = isPropΠ (λ g → isPropIsGroupHom H H)
        isPropIdentity = isPropΠ (λ h → GroupStr.is-set (snd H) (0ᴳ α h) h)
        isPropAssoc = isPropΠ3 (λ g g' h → GroupStr.is-set (snd H) ((g +ᴳ g') α h) (g α (g' α h)))

    IsGroupAction→IsGroupActionΣ : IsGroupAction G H _α_ → IsGroupActionΣ
    IsGroupAction→IsGroupActionΣ (isgroupaction isHom identity assoc) = isHom , identity , assoc

    IsGroupActionΣ→IsGroupAction : IsGroupActionΣ → IsGroupAction G H _α_
    IsGroupActionΣ→IsGroupAction (isHom , identity , assoc) = isgroupaction isHom identity assoc

    IsGroupActionΣIso : Iso (IsGroupAction G H _α_) IsGroupActionΣ
    Iso.fun IsGroupActionΣIso = IsGroupAction→IsGroupActionΣ
    Iso.inv IsGroupActionΣIso = IsGroupActionΣ→IsGroupAction 
    Iso.rightInv IsGroupActionΣIso = λ _ → refl
    Iso.leftInv IsGroupActionΣIso = λ _ → refl

open ActionΣTheory

isPropIsGroupAction : {ℓ ℓ' : Level }
                      (G : Group {ℓ}) (H : Group {ℓ'})
                      (_α_ : LeftActionStructure ⟨ G ⟩ ⟨ H ⟩)
                      → isProp (IsGroupAction G H _α_)
isPropIsGroupAction G H _α_ = isOfHLevelRespectEquiv 1
                                                     (invEquiv (isoToEquiv (IsGroupActionΣIso G H _α_)))
                                                     (isPropIsGroupActionΣ G H _α_)


module ActionNotationα {N : Group {ℓ}} {H : Group {ℓ'}} (Act : GroupAction H N) where
  _α_ = GroupAction._α_ Act
  private
    isGroupAction = GroupAction.isGroupAction Act
  α-id = IsGroupAction.identity isGroupAction
  α-hom = IsGroupAction.isHom isGroupAction
  α-assoc = IsGroupAction.assoc isGroupAction

module ActionLemmas {G : Group {ℓ}} {H : Group {ℓ'}} (Act : GroupAction G H) where
  open ActionNotationα {N = H} {H = G} Act
  open GroupNotationᴴ H
  open GroupNotationG G
  open MorphismLemmas {G = H} {H = H}
  open GroupLemmas

  abstract
    actOnUnit : (g : ⟨ G ⟩) → g α 0ᴴ ≡ 0ᴴ
    actOnUnit g = mapId (grouphom (g α_) (α-hom g))

    actOn-Unit : (g : ⟨ G ⟩) → g α (-ᴴ 0ᴴ) ≡ 0ᴴ
    actOn-Unit g = (cong (g α_) (invId H)) ∙ actOnUnit g

    actOn- : (g : ⟨ G ⟩) (h : ⟨ H ⟩) → g α (-ᴴ h) ≡ -ᴴ (g α h)
    actOn- g h = mapInv (grouphom (g α_) (α-hom g)) h

    -idAct : (h : ⟨ H ⟩) → (-ᴳ 0ᴳ) α h ≡ h
    -idAct h = (cong (_α h) (invId G)) ∙ (α-id h)

-- Examples
-- left adjoint action of a group on a normal subgroup
