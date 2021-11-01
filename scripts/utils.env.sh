if [[ -z "$PROJECT_DIR" ]]; then
    echo "[[ERROR]] PROJECT_DIR not set"
    exit 1
fi

for FILE in `find $PROJECT_DIR/scripts/utils -name \*.sh`; do
    source $FILE
done