module verytontine::vault {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::object::UID;
    use sui::event;

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

    /// Events
    public struct VaultCreated has copy, drop {
        vault_id: address,
        circle_id: address,
        creator: address,
    }

    public struct ContributionMade has copy, drop {
        vault_id: address,
        circle_id: address,
        contributor: address,
        amount: u64,
        round: u64,
    }

    public struct PayoutExecuted has copy, drop {
        vault_id: address,
        circle_id: address,
        beneficiary: address,
        amount: u64,
        round: u64,
    }

    /// The Vault object that holds circle funds
    public struct Vault has key, store {
        id: UID,
        circle_id: address,
        balance: Balance<SUI>,
        contributed_this_round: vector<address>,
    }

    /// Create a vault for a circle
    public fun create_vault(circle: &Circle, ctx: &mut TxContext) {
        let vault_id = object::new(ctx);
        let vault_address = object::uid_to_address(&vault_id);
        
        let vault = Vault {
            id: vault_id,
            circle_id: object::id_address(circle),
            balance: balance::zero(),
            contributed_this_round: vector::empty(),
        };
        
        event::emit(VaultCreated {
            vault_id: vault_address,
            circle_id: object::id_address(circle),
            creator: ctx.sender(),
        });
        
        transfer::share_object(vault);
    }

    /// Contribute funds to the vault
    public fun contribute(
        vault: &mut Vault,
        circle: &mut Circle,
        trust_score: &mut TrustScore,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let sender = ctx.sender();
        
        assert!(vault.circle_id == object::id_address(circle), EInvalidCircleLink);
        trust_score::check_owner(trust_score, sender);
        assert!(circle::is_member(circle, sender), ENotMember);
        assert!(payment.value() == circle::contribution_amount(circle), EWrongAmount);
        assert!(!vault.contributed_this_round.contains(&sender), EAlreadyContributed);

        let amount = payment.value();
        let coin_balance = payment.into_balance();
        vault.balance.join(coin_balance);
        vault.contributed_this_round.push_back(sender);
        trust_score::add_points(trust_score, 5);

        event::emit(ContributionMade {
            vault_id: object::id_address(vault),
            circle_id: vault.circle_id,
            contributor: sender,
            amount,
            round: circle::round_index(circle),
        });
    }

    /// Execute payout to the current beneficiary
    public fun execute_payout(
        vault: &mut Vault,
        circle: &mut Circle,
        ctx: &mut TxContext
    ) {
        let sender = ctx.sender();
        assert!(vault.circle_id == object::id_address(circle), EInvalidCircleLink);
        assert!(sender == circle::creator(circle), ENotCircleCreator);
        assert!(vault.contributed_this_round.length() == circle::member_count(circle), ERoundNotComplete);

        let beneficiary = circle::get_current_beneficiary(circle);
        let amount = vault.balance.value();
        assert!(amount > 0, EInsufficientVaultBalance);

        let payout_coin = coin::from_balance(vault.balance.split(amount), ctx);
        transfer::public_transfer(payout_coin, beneficiary);

        event::emit(PayoutExecuted {
            vault_id: object::id_address(vault),
            circle_id: vault.circle_id,
            beneficiary,
            amount,
            round: circle::round_index(circle),
        });

        vault.contributed_this_round = vector::empty();
        circle::next_round(circle);
    }

    /// Handle missed payment (penalty)
    public fun penalize_missed_payment(
        circle: &Circle,
        trust_score: &mut TrustScore,
        ctx: &mut TxContext
    ) {
        let sender = ctx.sender();
        assert!(sender == circle::creator(circle), ENotCircleCreator);
        trust_score::subtract_points(trust_score, 10);
    }
}
