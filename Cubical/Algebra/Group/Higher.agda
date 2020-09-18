
{-# OPTIONS --cubical --no-import-sorts --allow-unsolved-metas #-}

module Cubical.Algebra.Group.Higher where

open import Cubical.Core.Everything
open import Cubical.Data.Nat
open import Cubical.Data.Sigma
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Prelude hiding (comp)
open import Cubical.Foundations.Pointed
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Univalence
open import Cubical.Homotopy.Loopspace
open import Cubical.Homotopy.Connected
open import Cubical.Algebra.Group.Base
open import Cubical.Algebra.Group.EilenbergMacLane1
open import Cubical.HITs.EilenbergMacLane1

open import Cubical.Algebra.Group.Base
open import Cubical.Algebra.Group.Morphism
open import Cubical.Algebra.Group.MorphismProperties
open import Cubical.Foundations.GroupoidLaws
open import Cubical.Foundations.Equiv
open import Cubical.HITs.PropositionalTruncation renaming (rec to propRec)
open import Cubical.HITs.Truncation
open import Cubical.Functions.Surjection
open import Cubical.Functions.Embedding

import Cubical.Foundations.GroupoidLaws as GL

private
  variable
    ℓ ℓ' : Level


record HigherGroup ℓ : Type (ℓ-suc ℓ) where
  constructor highergroup
  field
    base : Pointed ℓ
    isConn : isConnected 2 (typ base)

record BGroup ℓ (n k : ℕ) : Type (ℓ-suc ℓ) where
  no-eta-equality
  constructor bgroup
  field
    base : Pointed ℓ
    isConn : isConnected (k + 1) (typ base)
    isTrun : isOfHLevel (n + k + 2) (typ base)

module _ where
  open BGroup
  η-BGroup : {n k : ℕ} {BG BH : BGroup ℓ n k}
             → (p : typ (base BG) ≡ typ (base BH))
             → (q : PathP (λ i → p i) (pt (base BG)) (pt (base BH)))
             → BG ≡ BH
  base (η-BGroup p q i) .fst = p i
  base (η-BGroup p q i) .snd = q i
  isConn (η-BGroup {k = k} {BG = BG} {BH = BH} p q i) = r i
    where
      r : PathP (λ i → isConnected (k + 1) (p i)) (isConn BG) (isConn BH)
      r = isProp→PathP (λ _ → isPropIsOfHLevel 0) (isConn BG) (isConn BH)
  isTrun (η-BGroup {n = n} {k = k} {BG = BG} {BH = BH} p q i) = s i
    where
      s : PathP (λ i → isOfHLevel (n + k + 2) (p i)) (isTrun BG) (isTrun BH)
      s = isProp→PathP (λ i → isPropIsOfHLevel (n + k + 2)) (isTrun BG) (isTrun BH)


BGroupHom : {n k : ℕ} (G : BGroup ℓ n k) (H : BGroup ℓ' n k) → Type (ℓ-max ℓ ℓ')
BGroupHom G H = (BGroup.base G) →∙ (BGroup.base H)

BGroupIso : {n k : ℕ} (G : BGroup ℓ n k) (H : BGroup ℓ' n k) → Type (ℓ-max ℓ ℓ')
BGroupIso G H = (BGroup.base G) ≃∙ (BGroup.base H)

BGroupIdIso : {n k : ℕ} (BG : BGroup ℓ n k) → BGroupIso BG BG
BGroupIdIso BG = idEquiv∙ (BGroup.base BG)

BGroupIso→≡ : {n k : ℕ} {BG BH : BGroup ℓ n k}
                (f : BGroupIso BG BH)
                → BG ≡ BH
BGroupIso→≡ {BG = BG} {BH = BH} f = η-BGroup (ua (≃∙→≃ f)) (toPathP ((uaβ ((≃∙→≃ f)) (pt (BGroup.base BG))) ∙ f .fst .snd))


-- getters
carrier : {ℓ : Level} {n k : ℕ} (G : BGroup ℓ n k) → Pointed ℓ
carrier {k = k} BG = (Ω^ k) base
  where
    open BGroup BG

basetype : {ℓ : Level} {n k : ℕ} (BG : BGroup ℓ n k) → Type ℓ
basetype BG = typ (BGroup.base BG)

basepoint : {ℓ : Level} {n k : ℕ} (BG : BGroup ℓ n k) → basetype BG
basepoint BG = pt (BGroup.base BG)

-- special cases
1BGroup : (ℓ : Level) → Type (ℓ-suc ℓ)
1BGroup ℓ = BGroup ℓ 0 1

-- first fundamental group of 1BGroups
π₁-1BGroup : {ℓ : Level} (BG : 1BGroup ℓ) → Group {ℓ}
π₁-1BGroup BG =
  makeGroup {G = (pt base) ≡ (pt base)}
            refl
            _∙_
            sym
            (isTrun (pt base) (pt base))
            GL.assoc
            (λ a → sym (GL.rUnit a))
            (λ g → sym (GL.lUnit g))
            GL.rCancel
            GL.lCancel
    where
      open BGroup BG

-- coercions
Group→1BGroup : (G : Group {ℓ}) → 1BGroup ℓ
BGroup.base (Group→1BGroup G) .fst = EM₁ G
BGroup.base (Group→1BGroup G) .snd = embase
BGroup.isConn (Group→1BGroup G) = EM₁Connected G
BGroup.isTrun (Group→1BGroup G) = EM₁Groupoid G

-- functoriality of π₁ on 1BGroups
module _ (BG : 1BGroup ℓ) (BH : 1BGroup ℓ') where
  private
    π₁BG = π₁-1BGroup BG
    π₁BH = π₁-1BGroup BH

  π₁-1BGroup-functor : BGroupHom BG BH → GroupHom π₁BG π₁BH
  GroupHom.fun (π₁-1BGroup-functor f) g = sym (snd f) ∙∙ cong (fst f) g ∙∙ snd f
  GroupHom.isHom (π₁-1BGroup-functor f) g g' = q
    where
      f₁ = fst f
      f₂ = snd f
      f₂- = sym (snd f)
      abstract
        q = (f₂- ∙∙ cong f₁ (g ∙ g') ∙∙ f₂)
                 ≡⟨ doubleCompPath-elim' f₂- (cong f₁ (g ∙ g')) f₂ ⟩
            f₂- ∙ cong f₁ (g ∙ g') ∙ f₂
              ≡⟨ cong (λ z → (f₂- ∙ z ∙ f₂))
                      (congFunct f₁ g g') ⟩
            f₂- ∙ (cong f₁ g ∙ cong f₁ g') ∙ f₂
              ≡⟨ cong (λ z → (f₂- ∙ (cong f₁ g ∙ z) ∙ f₂))
                      (lUnit (cong f₁ g')) ⟩
            f₂- ∙ (cong f₁ g ∙ refl ∙ cong f₁ g') ∙ f₂
              ≡⟨ cong (λ z → (f₂- ∙ (cong f₁ g ∙ z ∙ cong f₁ g') ∙ f₂))
                      (sym (rCancel f₂)) ⟩
            f₂- ∙ (cong f₁ g ∙ (f₂ ∙ f₂-) ∙ cong f₁ g') ∙ f₂
              ≡⟨ cong (λ z → (f₂- ∙ (cong f₁ g ∙ z) ∙ f₂))
                      (sym (assoc _ _ _)) ⟩
            f₂- ∙ (cong f₁ g ∙ (f₂ ∙ (f₂- ∙ cong f₁ g'))) ∙ f₂
              ≡⟨ cong (λ z → (f₂- ∙ z ∙ f₂))
                      (assoc _ _ _) ⟩
            (f₂- ∙ ((cong f₁ g ∙ f₂) ∙ (f₂- ∙ cong f₁ g')) ∙ f₂)
              ≡⟨ cong (f₂- ∙_)
                      (sym (assoc _ _ _)) ⟩
            (f₂- ∙ ((cong f₁ g ∙ f₂) ∙ ((f₂- ∙ cong f₁ g') ∙ f₂)))
              ≡⟨ cong (λ z → (f₂- ∙ ((cong f₁ g ∙ f₂) ∙ z)))
                      (sym (assoc _ _ _)) ⟩
            (f₂- ∙ ((cong f₁ g ∙ f₂) ∙ (f₂- ∙ cong f₁ g' ∙ f₂)))
              ≡⟨ assoc _ _ _ ⟩
            (f₂- ∙ cong f₁ g ∙ f₂) ∙ (f₂- ∙ cong f₁ g' ∙ f₂)
              ≡⟨ cong (_∙ (f₂- ∙ cong f₁ g' ∙ f₂))
                      (sym (doubleCompPath-elim' f₂- (cong f₁ g) f₂)) ⟩
            (f₂- ∙∙ cong f₁ g ∙∙ f₂) ∙ (f₂- ∙ cong f₁ g' ∙ f₂)
              ≡⟨ cong ((f₂- ∙∙ cong f₁ g ∙∙ f₂) ∙_)
                      (sym (doubleCompPath-elim' f₂- (cong f₁ g') f₂)) ⟩
            (f₂- ∙∙ cong f₁ g ∙∙ f₂) ∙ (f₂- ∙∙ cong f₁ g' ∙∙ f₂) ∎

-- the functorial action of EM₁ on groups
-- is a left inverse to the functorial action of π₁
-- on 1BGroups.
module _ (H : Group {ℓ}) (BG : 1BGroup ℓ') where
  private
    EM₁H = Group→1BGroup H
    π₁EM₁H = π₁-1BGroup EM₁H
    π₁BG = π₁-1BGroup BG

  -- from the EM construction it follows
  -- that there is a homomorphism H → π₁ (EM₁ H)
  H→π₁EM₁H : GroupHom H π₁EM₁H
  GroupHom.fun H→π₁EM₁H = Iso.inv (ΩEM₁Iso H)
  GroupHom.isHom H→π₁EM₁H = {!!}

  -- the promised functorial left inverse
  EM₁-functor-lInv : GroupHom π₁EM₁H π₁BG → BGroupHom EM₁H BG
  -- on objects
  EM₁-functor-lInv f .fst =
    rec' H
        (BGroup.isTrun BG)
        (basepoint BG)
        (GroupHom.fun (compGroupHom H→π₁EM₁H f))
        λ g h → sym (GroupHom.isHom (compGroupHom H→π₁EM₁H f) g h)
  -- pointedness is trivial
  EM₁-functor-lInv f .snd =
    (EM₁-functor-lInv f) .fst (basepoint EM₁H)
      ≡⟨ refl ⟩
    pt (BGroup.base BG) ∎

  -- this left inverse respects isomorphisms,
  -- first direction
  EM₁-functor-lInv-onIso : GroupEquiv π₁EM₁H π₁BG → BGroupIso EM₁H BG
  -- the underlying pointed map / BGroup homomorphism stays the same
  EM₁-functor-lInv-onIso f .fst = EM₁-functor-lInv (GroupEquiv.hom f)
  -- if f is an iso then the image of f is an embedding and surjective,
  -- all in all we have a pointed equivalence
  EM₁-functor-lInv-onIso f .snd = isEmbedding×isSurjection→isEquiv (isEmbedding-φ , isSurjection-φ)
    where
      φ : BGroupHom EM₁H BG
      φ = EM₁-functor-lInv (GroupEquiv.hom f)
      abstract
        isEmbedding-φ : isEmbedding (fst φ)
        isEmbedding-φ = {!!}

        isSurjection-φ : isSurjection (fst φ)
        isSurjection-φ g = propTruncΣ← (λ x → φ .fst x ≡ g) ∣ basepoint EM₁H , fst r ∣
          where
            r : isContr ∥ φ .fst (basepoint EM₁H) ≡ g ∥
            r = isContrRespectEquiv (invEquiv propTrunc≃Trunc1)
                                    (isConnectedPath 1
                                                     (BGroup.isConn BG)
                                                     (φ .fst (basepoint EM₁H))
                                                     g)

-- left inverse of below iso, used also in the right inverse proof
private
  module _ (G : Group {ℓ}) where
    leftInv : π₁-1BGroup (Group→1BGroup G) ≡ G
    leftInv = η-Group (ΩEM₁≡ G) {!!} {!!} {!!} {!!}

-- Isomorphism of the type of groups and the type of
-- pointed connected 1-types.
IsoGroup1BGroup : (ℓ : Level) → Iso (Group {ℓ}) (1BGroup ℓ)
Iso.fun (IsoGroup1BGroup ℓ) = Group→1BGroup
Iso.inv (IsoGroup1BGroup ℓ) = π₁-1BGroup
Iso.leftInv (IsoGroup1BGroup ℓ) = leftInv
-- For the right inverse we construct a pointed equivalence
-- which induces a path
-- (maybe we should use the URG structure to highlight this)
-- The pointed equivalence comes from the adjunction above with H:=π₁BG.
Iso.rightInv (IsoGroup1BGroup ℓ) BG = BGroupIso→≡ (EM₁-functor-lInv-onIso π₁BG BG φ)
  where
    π₁BG = π₁-1BGroup BG
    EM₁π₁BG = Group→1BGroup π₁BG
    π₁EM₁π₁BG = π₁-1BGroup EM₁π₁BG

    φ : GroupEquiv π₁EM₁π₁BG π₁BG
    φ = equivFun (invEquiv (GroupPath π₁EM₁π₁BG π₁BG)) (leftInv π₁BG)
