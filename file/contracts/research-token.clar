;; Research Token Contract
(impl-trait .research-token-trait.research-token-trait)

(define-constant contract-owner tx-sender)

;; Token metadata
(define-fungible-token research-token)

;; Error constants
(define-constant ERR-INSUFFICIENT-BALANCE (err u1))
(define-constant ERR-UNAUTHORIZED (err u2))

;; Token minting function
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR-UNAUTHORIZED)
    (ft-mint? research-token amount recipient)
  )
)

;; Token transfer function
(define-public (transfer 
  (amount uint)
  (sender principal)
  (recipient principal)
)
  (begin
    (asserts! 
      (is-eq tx-sender sender) 
      ERR-UNAUTHORIZED
    )
    (ft-transfer? research-token amount sender recipient)
  )
)

;; Get token balance
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance research-token account))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok (ft-get-total-supply research-token))
)