use starknet::ContractAddress;
#[derive(Copy, Drop, Serde)]
struct Scores {
    #[key]
    user_address: ContractAddress,
    user_score: felt252
}
// trait ScoreTrait {
//     fn set_score();
//     fn edit_score();
//     fn get_score() -> felt252;
// }


