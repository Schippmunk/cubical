{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.DStructures.Equivalences.XModS2G where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Univalence

open import Cubical.Functions.FunExtEquiv

open import Cubical.Homotopy.Base

open import Cubical.Data.Sigma
open import Cubical.Data.Unit

open import Cubical.Relation.Binary
open BinaryRelation

open import Cubical.Structures.Subtype
open import Cubical.Structures.Group
open import Cubical.Structures.LeftAction
open import Cubical.Structures.Group.Semidirect

open import Cubical.DStructures.Base
open import Cubical.DStructures.Meta.Properties
open import Cubical.DStructures.Meta.Combine
open import Cubical.DStructures.Meta.Isomorphism
open import Cubical.DStructures.Structures.Constant
open import Cubical.DStructures.Structures.Type
open import Cubical.DStructures.Structures.Group
open import Cubical.DStructures.Structures.Action
open import Cubical.DStructures.Structures.XModule
open import Cubical.DStructures.Structures.Strict2Group
open import Cubical.DStructures.Equivalences.GroupSplitEpiAction
open import Cubical.DStructures.Equivalences.PreXModReflGraph


private
  variable
    ℓ ℓ' ℓ'' ℓ₁ ℓ₁' ℓ₁'' ℓ₂ ℓA ℓA' ℓ≅A ℓ≅A' ℓB ℓB' ℓ≅B ℓC ℓ≅C ℓ≅ᴰ ℓ≅ᴰ' ℓ≅B' : Level

open Kernel
open GroupHom -- such .fun!
open GroupLemmas
open MorphismLemmas
open ActionLemmas

module _ (ℓ ℓ' : Level) where
  private
    ℓℓ' = ℓ-max ℓ ℓ'

    ℱ = IsoPreXModuleReflGraph ℓ ℓℓ'
    F = Iso.fun ℱ

    𝒮ᴰ-S2G = 𝒮ᴰ-ReflGraph\Peiffer

  -- ℋ : 𝒮ᴰ-♭iso F (𝒮ᴰ-XModule ℓ ℓℓ') (𝒮ᴰ-S2G ℓ ℓℓ')
  -- ℋ = {!!}
