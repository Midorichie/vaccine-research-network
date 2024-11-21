;; Research Token Trait Definition - V2
(define-trait research-token-trait
  (
    ;; Standard token balance retrieval
    (get-balance (principal) (response uint uint))
    
    ;; Enhanced token transfer with more comprehensive error handling
    (transfer (principal principal uint) (response bool uint))
    
    ;; Token total supply
    (get-total-supply () (response uint uint))
    
    ;; New: Added token minting capability
    (mint (uint principal) (response bool uint))
    
    ;; New: Added token burning capability
    (burn (uint principal) (response bool uint))
  )
)