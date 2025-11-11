if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <search_term>"
    exit 1
fi

SEARCH_TERM="$1"
GITHUB_API_URL="https://api.github.com/search/repositories"
QUERY="shodan+$SEARCH_TERM"

response=$(curl -s "${GITHUB_API_URL}?q=${QUERY}")


if echo "$response" | grep -q '"total_count": 0'; then
    echo "No repositories found containing the search term '${SEARCH_TERM}'."
    exit 0
fi


if ! echo "$response" | jq empty; then
    echo "Error: Failed to parse the GitHub API response. It may be malformed."
    exit 1
fi


echo -e "\nRepositories containing '${SEARCH_TERM}' Shodan queries:\n"

echo "$response" | jq -r '.items[] | "\(.full_name)\nDescription: \(.description // "No description available")\nURL: \(.html_url)\n"' | while IFS= read -r line; do

    if [[ $line =~ ^http ]]; then
        echo -e "Link: $line\n"
    else
        echo -e "$line\n"
    fi
done
