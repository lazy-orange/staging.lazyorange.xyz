resource "kubernetes_namespace" "tillerless" {
  count = var.create_tillerless_ns && var.enabled ? 1 : 0

  metadata {
    name = "tillerless"
  }
}