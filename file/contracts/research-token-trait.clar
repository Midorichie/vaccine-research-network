;; Research Token Trait Definition
(define-trait research-token-trait
  (
    ;; Standard token balance retrieval
    (get-balance (principal) (response uint uint))
    
    ;; Token transfer functionality
    (transfer (principal principal uint) (response bool uint))
    
    ;; Token total supply
    (get-total-supply () (response uint uint))
  )
)