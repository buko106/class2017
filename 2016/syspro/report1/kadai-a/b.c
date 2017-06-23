int mystrcmp(char *a, char *b)
{
	while (*a != '\0' && *a == *b) {
		++a; ++b;
	}
	return *a - *b;
}
