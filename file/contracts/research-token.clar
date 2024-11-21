;; Research Token Contract - V2
(impl-trait .research-token-trait.research-token-trait)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-INSUFFICIENT-BALANCE (err u1))
(define-constant ERR-UNAUTHORIZED (err u2))
(define-constant ERR-INVALID-AMOUNT (err u3))

;; Token metadata
(define-fungible-token research-token)

;; Token minting with enhanced validation
(define-public (mint (amount uint) (recipient principal))
  (begin
    ;; Prevent minting zero or negative amounts
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    ;; Restrict minting to contract owner
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    
    ;; Attempt token minting
    (ft-mint? research-token amount recipient)
  )
)

;; Token burning mechanism
(define-public (burn (amount uint) (owner principal))
  (begin
    ;; Verify sufficient balance
    (asserts! 
      (>= (ft-get-balance research-token owner) amount) 
      ERR-INSUFFICIENT-BALANCE
    )
    
    ;; Ensure only token owner can burn
    (asserts! (is-eq tx-sender owner) ERR-UNAUTHORIZED)
    
    ;; Burn tokens
    (ft-burn? research-token amount owner)
  )
)

;; Enhanced token transfer
(define-public (transfer 
  (amount uint)
  (sender principal)
  (recipient principal)
)
  (begin
    ;; Prevent transfers to same account
    (asserts! (not (is-eq sender recipient)) (err u4))
    
    ;; Verify sender authorization
    (asserts! 
      (is-eq tx-sender sender) 
      ERR-UNAUTHORIZED
    )
    
    ;; Verify sufficient balance
    (asserts! 
      (>= (ft-get-balance research-token sender) amount) 
      ERR-INSUFFICIENT-BALANCE
    )
    
    ;; Perform token transfer
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