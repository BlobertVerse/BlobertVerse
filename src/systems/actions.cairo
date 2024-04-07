use dojo_starter::models::moves::Direction;
use dojo_starter::models::position::{Position, Location, confirmLocation};
// use dojo_starter::models::scores::Scores;
// use dojo_starter::models::random::Dice;
use starknet::{ContractAddress, get_caller_address, contract_address_const};


// define the interface
#[dojo::interface]
trait IActions {
    fn startGame();
    fn fight_player(spaceOwner: ContractAddress, fighter: ContractAddress);
    fn checkFreePosition(user: ContractAddress, currentPosition: Position);
    fn changePosition(direction: Direction);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address, contract_address_const};
    // use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{
        position::{Position, Location, confirmLocation}, moves::{Moves, Direction}, scores::Scores,
        random::DiceTrait
    };

    // impl: implement functions specified in trait
    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        // start game ----
        fn startGame(world: IWorldDispatcher) {
            let player = get_caller_address();

            let player_position = get!(world, player, (Position));
            //    let contract_info = get!(world, get_contract_address, (confirmLocation));
            assert!(
                player_position.vec.x != 0 && player_position.vec.y != 0,
                "you are already in the game"
            );
            //    genertae random location.... two numbers here one for x axis and one for y axis...
            //    assert(contract_info.location.x != )\

            set!(
                world,
                (
                    Scores { user_address: player, user_score: 100 },
                    Position { player: player, vec: Location { x: 10, y: 10 } }
                )
            );
        }

        //  function  to initiate fight...
        fn fight_player(spaceOwner: ContractAddress, fighter: ContractAddress) {
            let mut dice = DiceTrait::new(6, 'seed');

            let first_number:felt252 = (dice.roll() * dice.roll()).into();
            let second_number:felt252  = (dice.roll() * dice.roll()).into();

            let mut space_owner_score = get!(world, spaceOwner, (Scores));
            let mut fighter_score = get!(world, fighter, (Scores));

            let new_space_owner_hp = space_owner_score.user_score - first_number;
            let new_fighter_score = fighter_score.user_score - second_number;

            if (new_space_owner_hp > new_fighter_score) {
                set!(
                    world,
                    (
                        Scores { user_address: fighter, user_score: 0 },
                        Position { player: fighter, vec: Location { x: 0, y: 0 } }
                    )
                );
            } else if (new_space_owner_hp == new_fighter_score) {
                fight_player(spaceOwner, fighter)
            } else {
                set!(
                    world,
                    (
                        Scores { user_address: spaceOwner, user_score: 0 },
                        Position { player: spaceOwner, vec: Location { x: 0, y: 0 } }
                    )
                );
            }
        // emit!(world, new_space_owner_hp, new_fighter_score )
        }


        //      check if new position is free for entry....

        fn checkFreePosition(user: ContractAddress, currentPosition: Position) {
            let mut freePosition_info = get!(world, currentPosition, (confirmLocation));
            assert((freePosition_info.number_of_participants <= 2), 'too many players');
            if (freePosition_info.available == false) {
        fight_player(freePosition_info.owner, user);
            } else {
                freePosition_info.available = true;
                freePosition_info.owner = user;
            }
        // assert(freePosition_info.available == false, );

        }

        // function to move players...
        fn changePosition(direction: Direction) {
            let user = get_caller_address();
            let mut currentPosition = get!(world, player, (Position));

            match direction {
                Direction::Left => currentPosition.vec.x -= 1,
                Direction::Right => currentPosition.vec.x += 1,
                Direction::Up => currentPosition.vec.y += 1,
                Direction::Down => currentPosition.vec.y -= 1
            }

        checkFreePosition(user, currentPosition);
        // move function
        }
    }
}

