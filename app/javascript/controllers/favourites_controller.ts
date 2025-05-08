import { Controller } from "@hotwired/stimulus"
import { db, IsSlugFavourited, GetFavouritesListId } from "../db"
import * as Turbo from "@hotwired/turbo"
import PlayerController from "./player_controller";

export default class extends Controller {
    static targets = ['grid', 'showFavouriteButton', 'featuredShow'];

    declare readonly gridTarget: HTMLElement;
    declare readonly hasGridTarget: boolean;

    declare readonly showFavouriteButtonTarget: HTMLElement;
    declare readonly hasShowFavouriteButtonTarget: boolean;

    connect() {
        if (this.hasGridTarget)
            this.renderFavourites();
        
        if (this.hasShowFavouriteButtonTarget)
            this.updateShowFavoriteButton(this.showFavouriteButtonTarget);
    }

    async togglePlayerFavourite(event) {
        console.log('togglePlayerFavourite');

        const button = event.currentTarget;
        const playerElement = button.closest('[data-controller="player"]');
        const slug = playerElement.dataset.slug;

        const isFavourite = await IsSlugFavourited(slug);
        const listId = await GetFavouritesListId();

        if (isFavourite)
            await db.listShows.where({ listId, slug }).delete();
        else
            await db.listShows.add({ listId, slug });

        playerElement.controller.updateFavouriteIcon();

        if (this.hasShowFavouriteButtonTarget)
            this.updateShowFavoriteButton(this.showFavouriteButtonTarget);
    }

    async toggleShowFavourite(event) {
        const button = event.currentTarget;
        const showElement = button.closest('[data-controller="show"]');
        const slug = showElement.dataset.slug;

        const isFavourite = await IsSlugFavourited(slug);
        const listId = await GetFavouritesListId();

        if (isFavourite)
            await db.listShows.where({ listId, slug }).delete();
        else
            await db.listShows.add({ listId, slug });

        this.updateShowFavoriteButton(button);

        const playerElement = document.querySelector('#player') as HTMLElement;
        const playerController = this.application.getControllerForElementAndIdentifier(playerElement, 'player') as PlayerController;

        playerController.updateFavouriteIcon();
    }

    async updateShowFavoriteButton(button) {
        const showElement = button.closest('[data-controller="show"]');
        const slug = showElement.dataset.slug;

        const isFavourite = await IsSlugFavourited(slug);
        
        const icon = button.querySelector('.favourite-icon');
        const text = button.querySelector('span');

        if (isFavourite) {
            icon.classList.add('active');
            button.classList.add('active');
            text.innerText = 'Remove from favourites';
        }
        else {
            icon.classList.remove('active');
            button.classList.remove('active');
            text.innerText = 'Add to favourites';
        }

        button.classList.remove('hidden');
    }

    async featuredShowTargetConnected(showEl) {
        const slug = showEl.getAttribute('href').split('/').pop();
        const isFavourite = await IsSlugFavourited(slug);

        const favouriteIcon = showEl.querySelector('.favourite-icon');

        if (isFavourite)
            favouriteIcon.classList.remove('hidden');
        else
            favouriteIcon.classList.add('hidden');
    }

    async renderFavourites() {
        this.gridTarget.setAttribute('busy', '');
        this.gridTarget.innerHTML = '';

        const favouritesSlugs = await this.getFavouritesSlugs();
        
        if (favouritesSlugs.length === 0) {
            this.gridTarget.innerHTML = `<p class="mb-5">No favourites yet!</p>`;
            this.gridTarget.classList.remove('responsive-grid');
            this.gridTarget.removeAttribute('busy');

            return;
        }

        try {
            const fetchPromises = favouritesSlugs.map(async (slug) => {
                const response = await fetch(`/${slug}/partials/featured`, {
                    method: "GET",
                    headers: {
                        Accept: "text/vnd.turbo-stream.html"
                    }
                });

                if (!response.ok) throw new Error('Fetch failed');

                const text = await response.text();

                await Turbo.renderStreamMessage(text);
            });

            await Promise.all(fetchPromises);
        } 
        catch (error) {
            this.gridTarget.innerHTML = `<p class="mb-5">Failed to load favourites.</p>`;
            this.gridTarget.classList.remove('responsive-grid');
        }

        this.gridTarget.removeAttribute('busy');
    }

    async getFavouritesSlugs() {
        const listId = await GetFavouritesListId();
        return (await db.listShows.where({ listId }).toArray()).map(ls => ls.slug);
    }
}