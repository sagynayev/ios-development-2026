import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var favoriteTitleLabel: UILabel!
    @IBOutlet weak var favoriteDescriptionLabel: UILabel!

    let favorites = [
        Favorite(
            imageName: "beshbarmak",
            title: "Beshbarmak",
            description: "Flat noodles with tender meat and onion broth"
        ),
        Favorite(
            imageName: "plov",
            title: "Plov",
            description: "Golden rice with beef carrots and aromatic spices"
        ),
        Favorite(
            imageName: "baursak",
            title: "Baursak",
            description: "Small pieces of soft dough fried until golden"
        ),
        Favorite(
            imageName: "manty",
            title: "Manty",
            description: "Steamed dumplings filled with juicy meat and onion"
        ),
        Favorite(
            imageName: "lagman",
            title: "Lagman",
            description: "Hand pulled noodles with meat vegetables and rich broth"
        ),
        Favorite(
            imageName: "pizza",
            title: "Pizza",
            description: "Crispy dough with tomato mozzarella and fresh basil"
        ),
        Favorite(
            imageName: "burger",
            title: "Burger",
            description: "Beef patty with cheese tomato lettuce and a toasted bun"
        ),
        Favorite(
            imageName: "sushi",
            title: "Sushi",
            description: "Rice rolls with salmon avocado and sesame"
        ),
        Favorite(
            imageName: "pasta",
            title: "Pasta",
            description: "Spaghetti with tomato meat sauce parmesan and basil"
        ),
        Favorite(
            imageName: "steak",
            title: "Steak",
            description: "Grilled beef served with roasted potatoes and herbs"
        )
    ]

    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        showFavorite(at: currentIndex)
    }

    @IBAction func showNextFavorite(_ sender: UIButton) {
        var nextIndex = currentIndex

        while nextIndex == currentIndex {
            nextIndex = Int.random(in: 0..<favorites.count)
        }

        showFavorite(at: nextIndex)
    }

    func showFavorite(at index: Int) {
        let favorite = favorites[index]

        favoriteImageView.image = UIImage(named: favorite.imageName)
        favoriteTitleLabel.text = favorite.title
        favoriteDescriptionLabel.text = favorite.description
        currentIndex = index
    }
}

