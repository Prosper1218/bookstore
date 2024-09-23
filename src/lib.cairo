#[derive(Copy, Drop, Serde, starknet::Store)]
struct Books {
    Book_id: felt252,
    price: u16,
    Book_name: felt252,
}

#[starknet::interface]
pub trait IBookShop<TContractState> {
    fn Add_Book(ref self: TContractState, Book_id: felt252, Book_name: felt252, price: u16);
    fn Del_Book(ref self: TContractState, Book_id: felt252);
    fn Update_Book(ref self: TContractState, Book_id: felt252, Newname: felt252);
    fn Get_Books(self: @TContractState, Book_id: felt252) -> Books;
}
//
//
#[starknet::contract]
pub mod ShopBooks {
    use super::{Books};
    use core::starknet::{
        storage::{Map, StorageMapReadAccess, StorageMapWriteAccess}, ContractAddress,
        get_caller_address,
    };
    //
    //
    #[storage]
    struct Storage {
        Books: Map<felt252, Books>, //mapping the studentId and the books struct
        BookKeeperAddress: ContractAddress
    }
    //
    //
    #[constructor]
    fn constructor(ref self: ContractState, Book_Keeper: ContractAddress) {
        self.BookKeeperAddress.write(Book_Keeper)
    }
    //
    //
    #[abi(embed_v0)]
    impl ShopBooks of super::IBookShop<ContractState> {
        fn Add_Book(ref self: ContractState, Book_id: felt252, Book_name: felt252, price: u16) {
            let address = self.BookKeeperAddress.read();
            assert(get_caller_address() == address, 'you are not a book-keeper');
            let Book = Books { Book_name: Book_name, Book_id: Book_id, price: price };
            self.Books.write(Book_id, Book)
        }

        fn Del_Book(ref self: ContractState, Book_id: felt252) {}

        fn Update_Book(ref self: ContractState, Book_id: felt252, Newname: felt252) {
            let address = self.BookKeeperAddress.read();
            assert(get_caller_address() == address, 'you are not a book-keeper');
            let mut Updated_book = self.Books.read(Book_id);
            Updated_book.Book_name = Newname;
            self.Books.write(Book_id, Updated_book)
        }

        fn Get_Books(self: @ContractState, Book_id: felt252) -> Books {
            self.Books.read(Book_id)
        }
    }
}