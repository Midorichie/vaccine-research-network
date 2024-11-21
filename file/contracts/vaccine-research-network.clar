;; Decentralized Vaccine Development Network
;; Primary Contract: Genome Data Sharing Platform

(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-submission (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-not-found (err u103))

;; Data Structures
(define-map research-submissions
    { 
        researcher: principal,
        genome-id: (string-ascii 50)
    }
    {
        submission-timestamp: uint,
        data-hash: (string-ascii 64),
        research-institution: (string-ascii 100),
        genome-type: (string-ascii 50)
    }
)

(define-map researcher-permissions
    principal
    {
        is-verified: bool,
        access-level: (string-ascii 20)
    }
)

;; Access Control Mechanism
(define-read-only (is-researcher-authorized (researcher principal))
    (default-to 
        { is-verified: false, access-level: "none" }
        (map-get? researcher-permissions researcher)
    )
)

;; Core Functions
(define-public (register-researcher 
    (institution (string-ascii 100))
    (access-level (string-ascii 20))
)
    (begin
        ;; Only contract owner can register researchers initially
        (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
        
        (map-set researcher-permissions 
            tx-sender 
            {
                is-verified: true, 
                access-level: access-level
            }
        )
        (ok true)
    )
)

(define-public (submit-genome-data
    (genome-id (string-ascii 50))
    (data-hash (string-ascii 64))
    (genome-type (string-ascii 50))
)
    (let 
        (
            (researcher-info (is-researcher-authorized tx-sender))
            (submission-timestamp block-height)
        )
        
        ;; Validate researcher authorization
        (asserts! (get is-verified researcher-info) err-unauthorized)
        
        ;; Prevent duplicate submissions
        (asserts! 
            (is-none 
                (map-get? research-submissions 
                    {
                        researcher: tx-sender, 
                        genome-id: genome-id
                    }
                )
            ) 
            err-already-exists
        )
        
        ;; Record genome submission
        (map-set research-submissions
            {
                researcher: tx-sender,
                genome-id: genome-id
            }
            {
                submission-timestamp: submission-timestamp,
                data-hash: data-hash,
                research-institution: "Default Institution",  ;; To be updated in v2
                genome-type: genome-type
            }
        )
        
        (ok true)
    )
)

;; Read-only Functions for Data Retrieval
(define-read-only (get-genome-submission 
    (researcher principal)
    (genome-id (string-ascii 50))
)
    (map-get? research-submissions 
        {
            researcher: researcher, 
            genome-id: genome-id
        }
    )
)

;; Governance and Management Functions
(define-public (update-researcher-access
    (researcher principal)
    (new-access-level (string-ascii 20))
)
    (begin
        ;; Restrict access to contract owner
        (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
        
        (map-set researcher-permissions
            researcher
            {
                is-verified: true,
                access-level: new-access-level
            }
        )
        
        (ok true)
    )
)

;; Initialization Function
(define-private (initialize-contract)
    (begin
        ;; Initial setup can be expanded in future versions
        (ok true)
    )
)

;; Contract Initialization
(initialize-contract)