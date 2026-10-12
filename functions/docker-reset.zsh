# Reset all Docker resources (containers, volumes, images)
docker_reset() {
  echo ""
  echo "🐳 Docker リセット"
  echo "  以下の操作が実行されます："
  echo "    • すべてのコンテナを停止・削除"
  echo "    • すべてのボリュームを削除"
  echo "    • 使用されていないイメージを削除"
  echo ""

  read -q "response?続行しますか？ (y/n) "
  echo ""

  if [[ "$response" != "y" ]]; then
    echo "キャンセルしました"
    return 1
  fi

  echo "実行中..."

  # Stop all containers
  docker compose down -v 2>/dev/null || true

  # Remove all stopped containers
  docker container prune -f --filter "until=0h" 2>/dev/null || true

  # Remove all unused volumes
  docker volume prune -f 2>/dev/null || true

  # Remove all unused images
  docker image prune -a -f 2>/dev/null || true

  # Remove all unused networks
  docker network prune -f 2>/dev/null || true

  echo ""
  echo "✅ Docker リセット完了"
  docker system df
  echo ""
}
