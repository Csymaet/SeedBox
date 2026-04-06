#!/bin/bash
ROLE_FILE="$1"

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

if [ -z "$ROLE_FILE" ]; then
	echo "用法: $0 <角色卡片路径>"
	exit 1
fi

# 支持绝对路径和相对路径
if [[ "$ROLE_FILE" = /* ]]; then
	# 绝对路径直接使用
	RESOLVED_ROLE_PATH="$ROLE_FILE"
else
	# 相对路径拼接 SEED_BOX
	RESOLVED_ROLE_PATH="$SEED_BOX/$ROLE_FILE"
fi

# 1. 输出角色卡片内容
if [ -f "$RESOLVED_ROLE_PATH" ]; then
	echo "=== 角色卡片 ==="
	cat "$RESOLVED_ROLE_PATH"
	echo ""
else
	echo "错误: 找不到角色卡片 $RESOLVED_ROLE_PATH"
	exit 1
fi

# 2. 输出知识卡片内容
echo "=== 关联知识卡片 ==="
KNOWLEDGE_NUMS=$(grep "^知识卡片：" "$RESOLVED_ROLE_PATH" | sed 's/知识卡片：//')

if [ -n "$KNOWLEDGE_NUMS" ]; then
	for NUM in $KNOWLEDGE_NUMS; do
		CARD=$(find "$SEED_BOX/002-知识卡片" -name "${NUM}-*.md" 2>/dev/null | head -1)
		if [ -f "$CARD" ]; then
			echo ""
			echo "--- $CARD ---"
			cat "$CARD"
		else
			echo "（未找到知识卡片: $NUM）"
		fi
	done
fi

# 3. 输出技能卡片内容
echo ""
echo "=== 关联技能卡片 ==="
SKILL_NUMS=$(grep "^技能：" "$RESOLVED_ROLE_PATH" | sed 's/技能：//')

if [ -n "$SKILL_NUMS" ]; then
	for NUM in $SKILL_NUMS; do
		SKILL_DIR=$(find "$SEED_BOX/003-技能" -type d -name "${NUM}-*" 2>/dev/null | head -1)
		if [ -f "$SKILL_DIR/SKILL.md" ]; then
			echo ""
			echo "--- $SKILL_DIR/SKILL.md ---"
			cat "$SKILL_DIR/SKILL.md"
		else
			echo "（未找到技能卡片: $NUM）"
		fi
	done
fi
