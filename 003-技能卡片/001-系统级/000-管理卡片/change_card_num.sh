#!/bin/bash
OLD_NUM="$1"
NEW_NUM="$2"

find_seed_box() {
	DIR="$(dirname "$0")"
	while [ "$DIR" != "/" ]; do
		if [ -d "$DIR/001-角色卡片" ] && [ -d "$DIR/002-知识卡片" ]; then
			echo "$DIR"
			return 0
		fi
		DIR="$(dirname "$DIR")"
	done
	echo "错误: 未找到 seed-box 根目录" >&2
	return 1
}

SEED_BOX="$(find_seed_box)"

if [ -z "$OLD_NUM" ] || [ -z "$NEW_NUM" ]; then
	echo "用法: $0 <旧编号> <新编号>"
	exit 1
fi

echo "=== 重命名知识卡片: $OLD_NUM -> $NEW_NUM ==="
echo ""

# 检查目标编号是否已存在
EXISTING=$(find "$SEED_BOX/002-知识卡片" -name "${NEW_NUM}-*.md" -type f)
if [ -n "$EXISTING" ]; then
	echo "错误: 目标编号 $NEW_NUM 已存在:"
	echo "$EXISTING"
	exit 1
fi

# 1. 查找并重命名文件
echo "--- 查找文件 ---"
FILES=$(find "$SEED_BOX/002-知识卡片" -name "${OLD_NUM}-*.md" -type f)
if [ -z "$FILES" ]; then
	echo "未找到编号为 $OLD_NUM 的文件"
	exit 1
fi

for FILE in $FILES; do
	DIR=$(dirname "$FILE")
	FILENAME=$(basename "$FILE")
	NEW_FILENAME=$(echo "$FILENAME" | sed "s/^${OLD_NUM}-/${NEW_NUM}-/")
	NEW_FILE="$DIR/$NEW_FILENAME"
	echo "重命名: $FILE -> $NEW_FILE"
	mv "$FILE" "$NEW_FILE"
done

echo ""

# 2. 更新角色卡片中的引用
echo "--- 更新角色卡片引用 ---"
for CARD in $(find "$SEED_BOX/001-角色卡片" -name "*.md" -type f); do
	if grep -q "^知识卡片：.*\b$OLD_NUM\b" "$CARD"; then
		echo "更新: $CARD"
		sed -i "/^知识卡片：/s/\b$OLD_NUM\b/$NEW_NUM/g" "$CARD"
	fi
done

echo ""
echo "完成"
