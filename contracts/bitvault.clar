;; Title: BitVault Protocol - Bitcoin-Native Collateralized Lending Platform
;;
;; Summary: An innovative DeFi lending ecosystem on Stacks that transforms Bitcoin holders
;;          into active DeFi participants through STX-collateralized borrowing with
;;          institutional-grade risk controls and automated position management.
;;
;; Description: BitVault Protocol bridges traditional Bitcoin holding with modern DeFi
;;              capabilities, enabling users to unlock liquidity from their STX holdings
;;              without selling. The protocol implements sophisticated collateral management,
;;              dynamic risk assessment, and community-driven liquidation mechanisms to
;;              create a sustainable lending marketplace. Designed for both retail users
;;              seeking capital efficiency and institutions requiring robust Bitcoin DeFi
;;              infrastructure with predictable risk parameters.

;; PROTOCOL CONSTANTS & ERROR HANDLING

;; Contract Administration
(define-constant CONTRACT-OWNER tx-sender)

;; System Error Codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-LOAN-NOT-FOUND (err u103))
(define-constant ERR-LOAN-ACTIVE (err u104))
(define-constant ERR-INSUFFICIENT-BALANCE (err u105))
(define-constant ERR-LIQUIDATION-FAILED (err u106))
(define-constant ERR-INVALID-PARAMETER (err u107))

;; Risk Management Parameters
(define-constant MAX-COLLATERAL-RATIO u500) ;; Maximum allowed collateral ratio (500%)
(define-constant MIN-COLLATERAL-RATIO u110) ;; Minimum required collateral ratio (110%)
(define-constant MAX-PROTOCOL-FEE u10) ;; Maximum protocol fee (10%)

;; PROTOCOL STATE VARIABLES

;; Core Risk Parameters
(define-data-var minimum-collateral-ratio uint u150) ;; Default: 150% - Conservative lending ratio
(define-data-var liquidation-threshold uint u130) ;; Default: 130% - Liquidation trigger point
(define-data-var protocol-fee uint u1) ;; Default: 1% - Protocol revenue fee

;; Global Protocol Metrics
(define-data-var total-deposits uint u0) ;; Total STX deposited as collateral
(define-data-var total-borrows uint u0) ;; Total STX borrowed from protocol

;; DATA STRUCTURES & MAPPINGS

;; Individual Loan Records
(define-map loans
  { loan-id: uint }
  {
    borrower: principal,
    collateral-amount: uint,
    borrowed-amount: uint,
    interest-rate: uint,
    start-height: uint,
    last-interest-update: uint,
    active: bool,
  }
)

;; User Portfolio Tracking
(define-map user-positions
  { user: principal }
  {
    total-collateral: uint, ;; Total STX deposited as collateral
    total-borrowed: uint, ;; Total STX borrowed
    loan-count: uint, ;; Number of active loans
  }
)

;; PRIVATE UTILITY FUNCTIONS

;; Calculate accumulated interest over time
(define-private (calculate-interest
    (principal uint)
    (rate uint)
    (blocks uint)
  )
  (let (
      (interest-per-block (/ (* principal rate) u10000))
      (total-interest (* interest-per-block blocks))
    )
    total-interest
  )
)