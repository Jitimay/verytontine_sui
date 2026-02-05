module verytontine::circle {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::{String};
    use std::vector;

    /// Error codes
    const ENotMember: u64 = 0;
    const EAlreadyMember: u64 = 1;

    /// The Circle object representing a savings group
    public struct Circle has key, store {
        id: UID,
        name: String,
        creator: address,
        members: vector<address>,
        contribution_amount: u64,
        round_index: u64,
        payout_order: vector<address>,
    }

    /// Create a new savings circle
    public entry fun create_circle(
        name: String,
        contribution_amount: u64,
        ctx: &mut TxContext
    ) {
        let creator = tx_context::sender(ctx);
        let mut members = vector::empty<address>();
        vector::push_back(&mut members, creator);

        let circle = Circle {
            id: object::new(ctx),
            name,
            creator,
            members,
            contribution_amount,
            round_index: 0,
            payout_order: vector::singleton(creator), // Initial order, can be shuffled later
        };

        transfer::share_object(circle);
    }

    /// Join an existing circle
    public entry fun join_circle(circle: &mut Circle, ctx: &mut TxContext) {
        let new_member = tx_context::sender(ctx);
        assert!(!vector::contains(&circle.members, &new_member), EAlreadyMember);
        
        vector::push_back(&mut circle.members, new_member);
        vector::push_back(&mut circle.payout_order, new_member);
    }

    /// Check if an address is a member of the circle
    public fun is_member(circle: &Circle, account: address): bool {
        vector::contains(&circle.members, &account)
    }

    /// Get the contribution amount for the circle
    public fun contribution_amount(circle: &Circle): u64 {
        circle.contribution_amount
    }

    /// Get the current beneficiary for the round
    public fun get_current_beneficiary(circle: &Circle): address {
        let num_members = vector::length(&circle.payout_order);
        *vector::borrow(&circle.payout_order, circle.round_index % num_members)
    }

    /// Increment the round index
    public(package) fun next_round(circle: &mut Circle) {
        circle.round_index = circle.round_index + 1;
    }

    /// Get the number of members in the circle
    public fun member_count(circle: &Circle): u64 {
        vector::length(&circle.members)
    }

    /// Get the creator of the circle
    public fun creator(circle: &Circle): address {
        circle.creator
    }
}
