module verytontine::trust_score {
    use sui::object::UID;

    /// Error codes
    const ENotOwner: u64 = 1;

    /// The TrustScore object for a user
    public struct TrustScore has key, store {
        id: UID,
        user: address,
        score: u64,
    }

    /// Initialize a trust score for a new user
    public fun initialize_trust_score(ctx: &mut TxContext) {
        let user = ctx.sender();
        let trust_score = TrustScore {
            id: object::new(ctx),
            user,
            score: 0,
        };
        transfer::share_object(trust_score);
    }

    /// Add points to a user's trust score
    public(package) fun add_points(score: &mut TrustScore, points: u64) {
        score.score = score.score + points;
    }

    /// Decrease points for a missed contribution
    public(package) fun subtract_points(score: &mut TrustScore, points: u64) {
        if (score.score >= points) {
            score.score = score.score - points;
        } else {
            score.score = 0;
        }
    }

    /// Get current score
    public fun get_score(score: &TrustScore): u64 {
        score.score
    }

    /// Get user address
    public fun get_user(score: &TrustScore): address {
        score.user
    }

    /// Assert that the trust score belongs to the given user
    public fun check_owner(score: &TrustScore, user: address) {
        assert!(score.user == user, ENotOwner);
    }
}
