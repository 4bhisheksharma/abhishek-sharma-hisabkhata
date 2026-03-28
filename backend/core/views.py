from django.shortcuts import render


def landing_page(request):
    return render(request, "landing_page.html")


def custom_404(request, exception):
    return render(request, "404.html", status=404)
