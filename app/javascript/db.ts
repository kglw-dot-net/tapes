import Dexie, { type EntityTable, type Transaction } from "dexie"

interface List {
    id: number; 
    name: string;
    isFavourites: 0 | 1;
    isShowsUserEditable: 0 | 1;
    isMetadataUserEditable: 0 | 1;
}

interface ListShow {
    id: number;
    slug: string;
    listId: number;
}

const db = new Dexie('GizzTapes') as Dexie & {
    lists: EntityTable<List, 'id'>,
    listShows: EntityTable<ListShow, 'id'>
};

db.version(1).stores({
    lists: '++id, name, isFavourites, isShowsUserEditable, isMetadataUserEditable',
    listShows: '++id, slug, listId, &[slug+listId]',
});

db.on("populate", (tx) => {
    (tx as Transaction & { lists: EntityTable<List, 'id'> }).lists.add({
        name: 'Favourites',
        isFavourites: 1,
        isShowsUserEditable: 1,
        isMetadataUserEditable: 0 
    });
});

export async function GetFavouritesListId() : Promise<number> {
    return (await db.lists.where({ isFavourites: 1 }).first()).id;
}

export async function IsSlugFavourited(slug: string) : Promise<boolean> {
    const listId = await GetFavouritesListId();
    return (await db.listShows.where({ listId, slug }).first()) !== undefined;
}

export type { List, ListShow };
export { db };
