resource "helm_release" "full-page" {
    name = "full-page"
    chart = "../helm/full-page"
}