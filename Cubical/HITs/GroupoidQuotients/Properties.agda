{-

Groupoid quotients:

-}

{-# OPTIONS --cubical --no-import-sorts --safe #-}
module Cubical.HITs.GroupoidQuotients.Properties where

open import Cubical.HITs.GroupoidQuotients.Base

open import Cubical.Core.Everything

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Equiv.HalfAdjoint
open import Cubical.Foundations.Univalence

open import Cubical.Data.Sigma

open import Cubical.Relation.Nullary
open import Cubical.Relation.Binary.Base

open import Cubical.HITs.PropositionalTruncation as PropTrunc using (∥_∥; ∣_∣; squash)
open import Cubical.HITs.SetTruncation as SetTrunc using (∥_∥₂; ∣_∣₂; squash₂)

-- Type quotients

private
  variable
    ℓA ℓR ℓ : Level
    A : Type ℓA
    R : A → A → Type ℓR
--    B : A // Rt → Type ℓ
--    C : A // Rt → A // Rt → Type ℓ

elimEq// : (Rt : BinaryRelation.isTrans R)
          {B : A // Rt → Type ℓ}
          (Bprop : (x : A // Rt) → isProp (B x))
          {x y : A // Rt}
          (eq : x ≡ y)
          (bx : B x)
          (by : B y) →
          PathP (λ i → B (eq i)) bx by
elimEq// Rt {B} Bprop {x = x} =
  J (λ y eq → ∀ bx by → PathP (λ i → B (eq i)) bx by) (λ bx by → Bprop x bx by)

elimProp : (Rt : BinaryRelation.isTrans R)
         → {B : A // Rt → Type ℓ}
         → ((x : A // Rt) → isProp (B x))
         → ((a : A) → B [ a ])
         → (x : A // Rt)
         → B x
elimProp Rt Bprop f [ x ] = f x
elimProp Rt Bprop f (eq// {a} {b} r i) = elimEq// Rt Bprop (eq// r) (f a) (f b) i
elimProp Rt Bprop f (comp// {a} {b} {c} r s i j) =
  isSet→isSetDep (λ x → isProp→isSet (Bprop x))
  (eq// r) (eq// (Rt a b c r s)) (λ j → [ a ]) (eq// s) (comp// r s)
  (λ i → elimEq// Rt Bprop (eq// r) (f a) (f b) i)
  (λ i → elimEq// Rt Bprop (eq// (Rt a b c r s)) (f a) (f c) i)
  (λ j → f a ) (λ j → elimEq// Rt Bprop (eq// s) (f b) (f c) j) i j
elimProp Rt Bprop f (squash// x y p q r s i j k) =
  isOfHLevel→isOfHLevelDep 3 (λ x → isSet→isGroupoid (isProp→isSet (Bprop x)))
  _ _ _ _ (λ j k → g (r j k)) (λ j k → g (s j k)) (squash// x y p q r s) i j k
  where
    g = elimProp Rt Bprop f

elimProp2 : (Rt : BinaryRelation.isTrans R)
          → {C : A // Rt → A // Rt → Type ℓ}
         → ((x y : A // Rt) → isProp (C x y))
         → ((a b : A) → C [ a ] [ b ])
         → (x y : A // Rt)
         → C x y
elimProp2 Rt Cprop f = elimProp Rt (λ x → isPropΠ (λ y → Cprop x y))
                                   (λ x → elimProp Rt (λ y → Cprop [ x ] y) (f x))

[]surjective : (Rt : BinaryRelation.isTrans R)
               → (x : A // Rt ) → ∃[ a ∈ A ] [ a ] ≡ x
[]surjective Rt = elimProp Rt (λ x → squash) (λ a → ∣ a , refl ∣)

elimSet : (Rt : BinaryRelation.isTrans R)
     → {B : A // Rt → Type ℓ}
     → ((x : A // Rt) → isSet (B x))
     → (f : (a : A) → B [ a ])
     → ({a b : A} (r : R a b) → PathP (λ i → B (eq// r i)) (f a) (f b))
     → (x : A // Rt)
     → B x
elimSet Rt Bset f feq [ a ] = f a
elimSet Rt Bset f feq (eq// r i) = feq r i
elimSet Rt Bset f feq (comp// {a} {b} {c} r s i j) =
  isSet→isSetDep Bset (eq// r) (eq// (Rt a b c r s)) (λ j → [ a ]) (eq// s) (comp// r s)
  (feq r) (feq (Rt a b c r s)) refl (feq s) i j
elimSet Rt Bset f feq (squash// x y p q r s i j k) =
  isOfHLevel→isOfHLevelDep 3 (λ x → isSet→isGroupoid (Bset x))
    _ _ _ _ (λ j k → g (r j k)) (λ j k → g (s j k)) (squash// x y p q r s) i j k
  where
    g = elimSet Rt Bset f feq

elim : (Rt : BinaryRelation.isTrans R)
     → {B : A // Rt → Type ℓ}
     → ((x : A // Rt) → isGroupoid (B x))
     → (f : (a : A) → B [ a ])
     → (feq : {a b : A} (r : R a b) → PathP (λ i → B (eq// r i)) (f a) (f b))
     → ({a b c : A} (r : R a b) (s : R b c)
           → SquareP (λ i j → B (comp// r s i j))
           (feq r) (feq (Rt a b c r s)) (λ j → f a) (feq s))
     → (x : A // Rt)
     → B x
elim Rt Bgpd f feq fcomp [ a ] = f a
elim Rt Bgpd f feq fcomp (eq// r i) = feq r i
elim Rt Bgpd f feq fcomp (comp// r s i j) = fcomp r s i j
elim Rt Bgpd f feq fcomp (squash// x y p q r s i j k) =
  isOfHLevel→isOfHLevelDep 3 Bgpd
    _ _ _ _ (λ j k → g (r j k)) (λ j k → g (s j k)) (squash// x y p q r s) i j k
  where
    g = elim Rt Bgpd f feq fcomp

rec : (Rt : BinaryRelation.isTrans R)
    → {B : Type ℓ}
    → isGroupoid B
    → (f : A → B)
    → (feq : {a b : A} (r : R a b) → f a ≡ f b)
    → ({a b c : A} (r : R a b) (s : R b c)
          → Square (feq r) (feq (Rt a b c r s)) refl (feq s))
    → (x : A // Rt)
    → B
rec Rt Bgpd = elim Rt (λ _ → Bgpd)

module BinarySetRelation {ℓA ℓR : Level} {A : Type ℓA} (R : Rel A A ℓR) where
  open BinaryRelation R

  isSetValued : Type (ℓ-max ℓA ℓR)
  isSetValued = (a b : A) → isSet (R a b)

