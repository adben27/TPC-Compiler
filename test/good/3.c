int main(void) {
	int key = 0;
	char image = initialiser_fenetre("Taquin en C", "bin/montagne.png");
	char plateau = initialisation_plateau();
	random_generation(plateau);
	while(key != 1) {
		split_print(image, plateau);
		MLV_update_window();
		key = keyboard_input();
		if(key == 1 || key == 2 || key == 3 || key == 4) {
			move(plateau, key);
		}
	}
	MLV_free_image(image);
	MLV_free_window();
    return 0;
}

