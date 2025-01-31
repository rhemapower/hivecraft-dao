;; HiveCraft DAO Core Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-proposal-not-found (err u102))
(define-constant err-dao-not-found (err u103))
(define-constant err-proposal-expired (err u104))

;; Data vars
(define-data-var next-dao-id uint u1)
(define-data-var next-proposal-id uint u1)

(define-map daos
  { dao-id: uint }
  {
    name: (string-utf8 64),
    description: (string-utf8 256),
    creator: principal,
    created-at: uint,
    voting-period: uint,
    quorum: uint
  }
)

(define-map proposals
  { proposal-id: uint }
  {
    dao-id: uint,
    title: (string-utf8 64),
    description: (string-utf8 256),
    proposer: principal,
    start-block: uint,
    end-block: uint,
    executed: bool,
    votes-for: uint,
    votes-against: uint
  }
)

;; Private functions
(define-private (get-next-dao-id)
  (let ((current-id (var-get next-dao-id)))
    (var-set next-dao-id (+ current-id u1))
    current-id))

(define-private (get-next-proposal-id)
  (let ((current-id (var-get next-proposal-id)))
    (var-set next-proposal-id (+ current-id u1))
    current-id))

;; Public functions
(define-public (create-dao 
  (name (string-utf8 64))
  (description (string-utf8 256))
  (voting-period uint)
  (quorum uint)
)
  (let ((dao-id (get-next-dao-id)))
    (if (and (> voting-period u0) (>= quorum u0))
      (ok (map-insert daos
        { dao-id: dao-id }
        {
          name: name,
          description: description,
          creator: tx-sender,
          created-at: block-height,
          voting-period: voting-period,
          quorum: quorum
        }))
      err-invalid-parameters)))

(define-public (submit-proposal
  (dao-id uint)
  (title (string-utf8 64))
  (description (string-utf8 256))
)
  (let ((proposal-id (get-next-proposal-id))
        (dao (unwrap! (map-get? daos { dao-id: dao-id }) err-dao-not-found)))
    (ok (map-insert proposals
      { proposal-id: proposal-id }
      {
        dao-id: dao-id,
        title: title,
        description: description,
        proposer: tx-sender,
        start-block: block-height,
        end-block: (+ block-height (get voting-period dao)),
        executed: false,
        votes-for: u0,
        votes-against: u0
      }))))

(define-public (vote
  (proposal-id uint)
  (support bool)
)
  (let ((proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) err-proposal-not-found)))
    (asserts! (<= block-height (get end-block proposal)) err-proposal-expired)
    (ok (map-set proposals
      { proposal-id: proposal-id }
      (merge proposal
        {
          votes-for: (if support (+ (get votes-for proposal) u1) (get votes-for proposal)),
          votes-against: (if (not support) (+ (get votes-against proposal) u1) (get votes-against proposal))
        })))))

(define-public (execute-proposal
  (proposal-id uint)
)
  (let ((proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) err-proposal-not-found))
        (dao (unwrap! (map-get? daos { dao-id: (get dao-id proposal) }) err-dao-not-found)))
    (asserts! (>= block-height (get end-block proposal)) err-proposal-expired)
    (asserts! (not (get executed proposal)) err-invalid-parameters)
    (asserts! (>= (get votes-for proposal) (get quorum dao)) err-invalid-parameters)
    (ok (map-set proposals
      { proposal-id: proposal-id }
      (merge proposal { executed: true })))))
