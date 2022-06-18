#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl htmlq

BASE_URL="http://sonic.sega.jp"

for i in {1..41}
do
  if [ "$i" == "1" ]; then
    page_url="$BASE_URL/SonicChannel/enjoy/index.html"
  else
    page_url="$BASE_URL/SonicChannel/enjoy/index_$i.html"
  fi

  page_html=$(curl --silent "$page_url")
  links_in_page=$(htmlq '#contents-archive' --attribute href a <<< "$page_html")

  mkdir -p output/calendar
  mkdir -p output/wallpaper/pc
  mkdir -p output/wallpaper/sp
  mkdir -p output/papercraft
  mkdir -p output/coloring
  mkdir -p output/etc

  for url in $links_in_page
  do
    (
    pattern="\/(\w*)\.(pdf|png|jpg|jpeg)"
    [[ "$url" =~ $pattern ]]
    filename="${BASH_REMATCH[1]}"
    extension="${BASH_REMATCH[2]}"

    # Get type of file to figure out what to do
    type_pattern="([a-z]+)_"
    [[ "$filename" =~ $type_pattern ]]

    type="${BASH_REMATCH[1]}"

    echo "Downloading $filename.$extension"

    if [[ "$type" == "wallpaper" ]]; then
        subtype_pattern="_(sp|pc)"
        [[ "$filename" =~ $subtype_pattern ]]
        subtype="${BASH_REMATCH[1]}"

	output="$type/$subtype"
    else
	output="$type"
    fi

    curl -o "./output/$output/$filename.$extension" "$BASE_URL$url" --silent
    ) &
  done
done

wait
