module verytontine::vault {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::vector;

    use verytontine::circle::{Self, Circle};
    use verytontine::trust_score::{Self, TrustScore};

    /// Error codes
    const ENotMember: u64 = 0;
    const EWrongAmount: u64 = 1;
    const EAlreadyContributed: u64 = 2;
    const EInsufficientVaultBalance: u64 = 3;
    const EInvalidCircleLink: u64 = 4;
    const ENotCircleCreator: u64 = 5;
    const ERoundNotComplete: u64 = 6;

    /// The Vault object that holds circle funds
    public struct Vault has key, store {
        id: UID,
        circle_id: address, // Linking to the Circle's object ID address
        balance: Balance<SUI>,
        contributed_this_round: vector<address>,
    }

    /// Create a vault for a circle
    public entry fun create_vault(circle: &Circle, ctx: &mut TxContext) {
        let vault = Vault {
            id: object::new(ctx),
            circle_id: object::id_address(circle),
            balance: balance::zero(),
            contributed_this_round: vector::empty(),
        };
        transfer::share_object(vault);
    }

    /// Contribute funds to the vault
    public entry fun contribute(
        vault: &mut Vault,
        circle: &mut Circle,
        trust_score: &mut TrustScore,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        // Link verification
        assert!(vault.circle_id == object::id_address(circle), EInvalidCircleLink);

        // Ownership check for TrustScore
        trust_score::check_owner(trust_score, sender);

        // Basic checks
        assert!(circle::is_member(circle, sender), ENotMember);
        assert!(coin::value(&payment) == circle::contribution_amount(circle), EWrongAmount);
        assert!(!vector::contains(&vault.contributed_this_round, &sender), EAlreadyContributed);

        // Add to vault balance
        let coin_balance = coin::into_balance(payment);
        balance::join(&mut vault.balance, coin_balance);

        // Record contribution
        vector::push_back(&mut vault.contributed_this_round, sender);

        // Reward trust score
        trust_score::add_points(trust_score, 5);

        // Check if all members have contributed to trigger payout
        // For MVP simplification, we assume the circle manages its member list
        // and we trigger payout manually or automatically if logic matches
        // Here we'll just check if round is complete
    }

    /// Execute payout to the current beneficiary
    public fun execute_payout(
        vault: &mut Vault,
        circle: &mut Circle,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        // Link verification
        assert!(vault.circle_id == object::id_address(circle), EInvalidCircleLink);

        // Admin check (Only creator can trigger payout for MVP)
        assert!(sender == circle::creator(circle), ENotCircleCreator);

        // Integrity check: Everyone must have contributed
        assert!(vector::length(&vault.contributed_this_round) == circle::member_count(circle), ERoundNotComplete);

        let beneficiary = circle::get_current_beneficiary(circle);
        let amount = balance::value(&vault.balance);
        
        assert!(amount > 0, EInsufficientVaultBalance);

        // Transfer funds
        let payout_coin = coin::from_balance(balance::split(&mut vault.balance, amount), ctx);
        transfer::public_transfer(payout_coin, beneficiary);

        // Clear round contributions and move to next round
        vault.contributed_this_round = vector::empty();
        circle::next_round(circle);
    }

    /// Handle missed payment (penalty)
    public fun penalize_missed_payment(
        circle: &Circle,
        trust_score: &mut TrustScore,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        // Only creator can penalize
        assert!(sender == circle::creator(circle), ENotCircleCreator);

        // Logic to be called by circle admin if a round ends without contribution
        trust_score::subtract_points(trust_score, 10);
    }
}
