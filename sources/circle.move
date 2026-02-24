module verytontine::circle {
    use sui::object::UID;
    use std::string::String;
    use sui::event;

    /// Error codes
    const EAlreadyMember: u64 = 1;

    /// Events
    public struct CircleCreated has copy, drop {
        circle_id: address,
        name: String,
        creator: address,
        contribution_amount: u64,
    }

    public struct MemberJoined has copy, drop {
        circle_id: address,
        member: address,
        total_members: u64,
    }

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
    public fun create_circle(
        name: String,
        contribution_amount: u64,
        ctx: &mut TxContext
    ) {
        let creator = ctx.sender();
        let mut members = vector::empty<address>();
        members.push_back(creator);

        let circle_id = object::new(ctx);
        let circle_address = object::uid_to_address(&circle_id);

        let circle = Circle {
            id: circle_id,
            name,
            creator,
            members,
            contribution_amount,
            round_index: 0,
            payout_order: vector::singleton(creator),
        };

        event::emit(CircleCreated {
            circle_id: circle_address,
            name,
            creator,
            contribution_amount,
        });

        transfer::share_object(circle);
    }

    /// Join an existing circle
    public fun join_circle(circle: &mut Circle, ctx: &mut TxContext) {
        let new_member = ctx.sender();
        assert!(!circle.members.contains(&new_member), EAlreadyMember);
        
        circle.members.push_back(new_member);
        circle.payout_order.push_back(new_member);

        event::emit(MemberJoined {
            circle_id: object::id_address(circle),
            member: new_member,
            total_members: circle.members.length(),
        });
    }

    /// Check if an address is a member of the circle
    public fun is_member(circle: &Circle, account: address): bool {
        circle.members.contains(&account)
    }

    /// Get the contribution amount for the circle
    public fun contribution_amount(circle: &Circle): u64 {
        circle.contribution_amount
    }

    /// Get the current beneficiary for the round
    public fun get_current_beneficiary(circle: &Circle): address {
        let num_members = circle.payout_order.length();
        *circle.payout_order.borrow(circle.round_index % num_members)
    }

    /// Get the current round index
    public fun round_index(circle: &Circle): u64 {
        circle.round_index
    }

    /// Increment the round index
    public(package) fun next_round(circle: &mut Circle) {
        circle.round_index = circle.round_index + 1;
    }

    /// Get the number of members in the circle
    public fun member_count(circle: &Circle): u64 {
        circle.members.length()
    }

    /// Get the creator of the circle
    public fun creator(circle: &Circle): address {
        circle.creator
    }
}
