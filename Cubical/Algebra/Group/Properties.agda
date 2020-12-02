{-# OPTIONS --cubical --no-import-sorts --safe #-}

module Cubical.Algebra.Group.Properties where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Structure
open import Cubical.Data.Sigma
open import Cubical.Algebra.Semigroup
open import Cubical.Algebra.Monoid
open import Cubical.Algebra.Group.Base

private
  variable
    ℓ ℓ' ℓ'' : Level

module GroupLemmas (G : Group {ℓ}) where
  open GroupStr (snd G)
  abstract
    simplL : (a : ⟨ G ⟩) {b c : ⟨ G ⟩} → a + b ≡ a + c → b ≡ c
    simplL a {b} {c} p =
       b
        ≡⟨ sym (lid b) ∙ cong (_+ b) (sym (invl a)) ∙ sym (assoc _ _ _) ⟩
      - a + (a + b)
        ≡⟨ cong (- a +_) p ⟩
      - a + (a + c)
        ≡⟨ assoc _ _ _ ∙ cong (_+ c) (invl a) ∙ lid c ⟩
      c ∎

    simplR : {a b : ⟨ G ⟩} (c : ⟨ G ⟩) → a + c ≡ b + c → a ≡ b
    simplR {a} {b} c p =
      a
        ≡⟨ sym (rid a) ∙ cong (a +_) (sym (invr c)) ∙ assoc _ _ _ ⟩
      (a + c) - c
        ≡⟨ cong (_- c) p ⟩
      (b + c) - c
        ≡⟨ sym (assoc _ _ _) ∙ cong (b +_) (invr c) ∙ rid b ⟩
      b ∎

    invInvo : (a : ⟨ G ⟩) → - (- a) ≡ a
    invInvo a = simplL (- a) (invr (- a) ∙ sym (invl a))

    invId : - 0g ≡ 0g
    invId = simplL 0g (invr 0g ∙ sym (lid 0g))

    idUniqueL : {e : ⟨ G ⟩} (x : ⟨ G ⟩) → e + x ≡ x → e ≡ 0g
    idUniqueL {e} x p = simplR x (p ∙ sym (lid _))

    idUniqueR : (x : ⟨ G ⟩) {e : ⟨ G ⟩} → x + e ≡ x → e ≡ 0g
    idUniqueR x {e} p = simplL x (p ∙ sym (rid _))

    invUniqueL : {g h : ⟨ G ⟩} → g + h ≡ 0g → g ≡ - h
    invUniqueL {g} {h} p = simplR h (p ∙ sym (invl h))

    invUniqueR : {g h : ⟨ G ⟩} → g + h ≡ 0g → h ≡ - g
    invUniqueR {g} {h} p = simplL g (p ∙ sym (invr g))

    invDistr : (a b : ⟨ G ⟩) → - (a + b) ≡ - b - a
    invDistr a b = sym (invUniqueR γ) where
      γ : (a + b) + (- b - a) ≡ 0g
      γ = (a + b) + (- b - a)
            ≡⟨ sym (assoc _ _ _) ⟩
          a + b + (- b) + (- a)
            ≡⟨ cong (a +_) (assoc _ _ _ ∙ cong (_+ (- a)) (invr b)) ⟩
          a + (0g - a)
            ≡⟨ cong (a +_) (lid (- a)) ∙ invr a ⟩
          0g ∎

    invDistr₃ : (a b c : Carrier) → - ((a + b) + c) ≡ (- c) + ((- b) - a)
    invDistr₃ a b c = (invDistr (a + b) c) ∙ (cong ((- c) +_) (invDistr a b))

    invDistr₄ : (a b c d : Carrier) → - (((a + b) + c) + d) ≡ (- d) + ((- c) + ((- b) - a))
    invDistr₄ a b c d = (invDistr₃ (a + b) c d) ∙ (cong (λ x → (- d) + ((- c) + x)) (invDistr a b))

    assoc-rCancel : (a b : Carrier) → a + ((- a) + b) ≡ b
    assoc-rCancel a b = (assoc a (- a) b) ∙∙ (cong (_+ b) (invr a)) ∙∙ (lid b)

    assoc-lCancel-lId : (a b : Carrier) → (- a) + (a + b) ≡ b
    assoc-lCancel-lId a b = assoc (- a) a b ∙∙ (cong (_+ b) (invl a)) ∙∙ (lid b)

    assoc-assoc : (a b c d : Carrier) → a + ((b + c) + d) ≡ ((a + b) + c) + d
    assoc-assoc a b c d = assoc a (b + c) d ∙ cong (_+ d) (assoc a b c)

    assoc-c--r- : (a b c d : Carrier) → (a + (b + c)) + d ≡ a + (b + (c + d))
    assoc-c--r- a b c d = sym (assoc a (b + c) d) ∙ cong (a +_) (sym (assoc b c d))
   

    rCancel-lId : (a b : Carrier) → (a - a) + b ≡ b
    rCancel-lId a b = cong (_+ b) (invr a) ∙ lid b

    lCancel-lId : (a b : Carrier) → ((- a) + a) + b ≡ b
    lCancel-lId a b = cong (_+ b) (invl a) ∙ lid b

    rCancel-rId : (a b : Carrier) → a + (b - b) ≡ a
    rCancel-rId a b = (cong (a +_) (invr b)) ∙ (rid a)

    lCancel-rId : (a b : Carrier) → a + (- b + b) ≡ a
    lCancel-rId a b = (cong (a +_) (invl b)) ∙ (rid a)

    assoc⁻-assocr-lCancel-lId : (a b c : Carrier) → (a - b) + (b + c) ≡ a + c
    assoc⁻-assocr-lCancel-lId a b c = (sym (assoc a (- b) (b + c))) ∙ (cong (a +_) (assoc-lCancel-lId b c))

    lId-lId : (a : Carrier) → 0g + (0g + a) ≡ a
    lId-lId a = (lid (0g + a)) ∙ (lid a)

isPropIsGroup : {G : Type ℓ} (0g : G) (_+_ : G → G → G) (-_ : G → G)
             → isProp (IsGroup 0g _+_ -_)
IsGroup.isMonoid (isPropIsGroup 0g _+_ -_ g1 g2 i) = isPropIsMonoid _ _ (IsGroup.isMonoid g1) (IsGroup.isMonoid g2) i
IsGroup.inverse (isPropIsGroup 0g _+_ -_ g1 g2 i) = isPropInv (IsGroup.inverse g1) (IsGroup.inverse g2) i
  where
  isSetG : isSet _
  isSetG = IsSemigroup.is-set (IsMonoid.isSemigroup (IsGroup.isMonoid g1))

  isPropInv : isProp ((x : _) → ((x + (- x)) ≡ 0g) × (((- x) + x) ≡ 0g))
  isPropInv = isPropΠ λ _ → isProp× (isSetG _ _) (isSetG _ _)
