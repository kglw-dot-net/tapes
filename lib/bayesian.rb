# frozen_string_literal: true

class Bayesian
  # weighted rating (WR) = (v ÷ (v+m)) x R + (m ÷ (v+m)) x C
  #
  # Where:
  # r = average for the title (mean)
  # v = number of ratings for the title
  # m = minimum ratings required to be listed in the Top Rated 250 chart (currently 25,000)
  # c = the mean rating across the whole report

  def self.calculate(mean_rating, count_ratings, minimum_ratings, all_shows_mean_rating)
    (count_ratings / (count_ratings + minimum_ratings)) * mean_rating +
      (minimum_ratings / (count_ratings + minimum_ratings)) * all_shows_mean_rating
  end
end
