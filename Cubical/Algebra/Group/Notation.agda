
{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.Algebra.Group.Notation where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.HLevels
open import Cubical.Algebra.Group.Base

module GroupNotationG {ℓ : Level} ((_ , G) : Group {ℓ}) where
  0ᴳ = GroupStr.0g G
  _+ᴳ_ = GroupStr._+_ G
  -ᴳ_ = GroupStr.-_ G
  _-ᴳ_ = GroupStr._-_ G
  lIdᴳ = GroupStr.lid G
  rIdᴳ = GroupStr.rid G
  lCancelᴳ = GroupStr.invl G
  rCancelᴳ = GroupStr.invr G
  assocᴳ = GroupStr.assoc G
  setᴳ = GroupStr.is-set G

module GroupNotationᴴ {ℓ : Level} ((_ , G) : Group {ℓ}) where
  0ᴴ = GroupStr.0g G
  _+ᴴ_ = GroupStr._+_ G
  -ᴴ_ = GroupStr.-_ G
  _-ᴴ_ = GroupStr._-_ G
  lIdᴴ = GroupStr.lid G
  rIdᴴ = GroupStr.rid G
  lCancelᴴ = GroupStr.invl G
  rCancelᴴ = GroupStr.invr G
  assocᴴ = GroupStr.assoc G
  setᴴ = GroupStr.is-set G

module GroupNotation₀ {ℓ : Level} ((_ , G) : Group {ℓ}) where
  0₀ = GroupStr.0g G
  _+₀_ = GroupStr._+_ G
  -₀_ = GroupStr.-_ G
  _-₀_ = GroupStr._-_ G
  lId₀ = GroupStr.lid G
  rId₀ = GroupStr.rid G
  lCancel₀ = GroupStr.invl G
  rCancel₀ = GroupStr.invr G
  assoc₀ = GroupStr.assoc G
  set₀ = GroupStr.is-set G

module GroupNotation₁ {ℓ : Level} ((_ , G) : Group {ℓ}) where
  0₁ = GroupStr.0g G
  _+₁_ = GroupStr._+_ G
  -₁_ = GroupStr.-_ G
  _-₁_ = GroupStr._-_ G
  lId₁ = GroupStr.lid G
  rId₁ = GroupStr.rid G
  lCancel₁ = GroupStr.invl G
  rCancel₁ = GroupStr.invr G
  assoc₁ = GroupStr.assoc G
  set₁ = GroupStr.is-set G
