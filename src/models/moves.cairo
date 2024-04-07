use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Moves {
    #[key]
    player: ContractAddress,
    next_direction: Direction
}

#[derive(Serde, Copy, Drop, Introspect)]
enum Direction {
    Left,
    Right,
    Up,
    Down,
}


impl DirectionIntoFelt252 of Into<Direction, felt252> {
    fn into(self: Direction) -> felt252 {
        match self {
            Direction::Left => 1,
            Direction::Right => 2,
            Direction::Up => 3,
            Direction::Down => 4,
        }
    }
}

