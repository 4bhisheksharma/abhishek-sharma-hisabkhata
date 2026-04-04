from django.shortcuts import render


def landing_page(request):
    return render(request, "landing_page.html")


def not_found_page(request, *args, **kwargs):
    return render(request, "404.html", status=404)


def custom_404(request, exception):
    return not_found_page(request)
