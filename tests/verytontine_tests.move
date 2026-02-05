#[test_only]
module verytontine::tests {
    use sui::test_scenario::{Self, ctx};
    use std::string;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::transfer;

    use verytontine::circle::{Self, Circle};
    use verytontine::vault::{Self, Vault};
    use verytontine::trust_score::{Self, TrustScore};

    #[test]
    fun test_full_cycle() {
        let admin = @0xAD;
        let member1 = @0x1;
        let member2 = @0x2;

        let mut scenario = test_scenario::begin(admin);
        
        // 1. Create Circle
        {
            circle::create_circle(
                string::utf8(b"Village Savings"),
                100, // contribution amount
                test_scenario::ctx(&mut scenario)
            );
        };

        // 2. Members Join
        test_scenario::next_tx(&mut scenario, member1);
        {
            let mut circle = test_scenario::take_shared<Circle>(&scenario);
            circle::join_circle(&mut circle, test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(circle);
        };

        test_scenario::next_tx(&mut scenario, member2);
        {
            let mut circle = test_scenario::take_shared<Circle>(&scenario);
            circle::join_circle(&mut circle, test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(circle);
        };

        // 3. Initialize Trust Scores
        test_scenario::next_tx(&mut scenario, member1);
        {
            trust_score::initialize_trust_score(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, member2);
        {
            trust_score::initialize_trust_score(test_scenario::ctx(&mut scenario));
        };

        // 4. Create Vault
        test_scenario::next_tx(&mut scenario, admin);
        {
            let circle = test_scenario::take_shared<Circle>(&scenario);
            vault::create_vault(&circle, test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(circle);
        };

        // 5. Contribute (Member 1)
        test_scenario::next_tx(&mut scenario, member1);
        {
            let mut vault = test_scenario::take_shared<Vault>(&scenario);
            let mut circle = test_scenario::take_shared<Circle>(&scenario);
            
            let mut score = test_scenario::take_shared<TrustScore>(&scenario);
            if (trust_score::get_user(&score) != member1) {
                test_scenario::return_shared(score);
                score = test_scenario::take_shared<TrustScore>(&scenario); 
            };
            
            let payment = coin::mint_for_testing<SUI>(100, test_scenario::ctx(&mut scenario));
            vault::contribute(&mut vault, &mut circle, &mut score, payment, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared(vault);
            test_scenario::return_shared(circle);
            test_scenario::return_shared(score);
        };

        // 6. Contribute (Member 2)
        test_scenario::next_tx(&mut scenario, member2);
        {
            let mut vault = test_scenario::take_shared<Vault>(&scenario);
            let mut circle = test_scenario::take_shared<Circle>(&scenario);
            
            let mut score = test_scenario::take_shared<TrustScore>(&scenario);
            if (trust_score::get_user(&score) != member2) {
                test_scenario::return_shared(score);
                score = test_scenario::take_shared<TrustScore>(&scenario);
            };
            
            let payment = coin::mint_for_testing<SUI>(100, test_scenario::ctx(&mut scenario));
            vault::contribute(&mut vault, &mut circle, &mut score, payment, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared(vault);
            test_scenario::return_shared(circle);
            test_scenario::return_shared(score);
        };

        // 7. Initialize and Contribute (Admin)
        test_scenario::next_tx(&mut scenario, admin);
        {
            trust_score::initialize_trust_score(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, admin);
        {
            let mut vault = test_scenario::take_shared<Vault>(&scenario);
            let mut circle = test_scenario::take_shared<Circle>(&scenario);
            let mut score = test_scenario::take_shared<TrustScore>(&scenario);
            
            let payment = coin::mint_for_testing<SUI>(100, test_scenario::ctx(&mut scenario));
            vault::contribute(&mut vault, &mut circle, &mut score, payment, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared(vault);
            test_scenario::return_shared(circle);
            test_scenario::return_shared(score);
        };

        // 8. Payout (Admin)
        test_scenario::next_tx(&mut scenario, admin);
        {
            let mut vault = test_scenario::take_shared<Vault>(&scenario);
            let mut circle = test_scenario::take_shared<Circle>(&scenario);
            
            vault::execute_payout(&mut vault, &mut circle, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared(vault);
            test_scenario::return_shared(circle);
        };

        test_scenario::end(scenario);
    }
}
