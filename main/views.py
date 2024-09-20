from django.views.generic import TemplateView
from django.core.mail import send_mail
from django.contrib import messages
from .forms import ContactForm


class IndexView(TemplateView):
    template_name = 'main/index.html'

    def get(self, request, *args, **kwargs):
        form = ContactForm()
        return self.render_to_response({'form': form})

    def post(self, request, *args, **kwargs):
        form = ContactForm(request.POST)
        if form.is_valid():
            name = form.cleaned_data['name']
            email = form.cleaned_data['email']
            subject = form.cleaned_data['subject']
            message = form.cleaned_data['message']

            # Отправка письма
            send_mail(
                subject=f"Contact Form: {subject}",
                message=f"Name: {name}\nEmail: {email}\n\nMessage:\n{message}",
                from_email='EMAIL_HOST_USER',
                recipient_list=['d.s.puliaiev@gmail.com'],
                fail_silently=False,
            )

            # Сообщение об успешной отправке
            messages.success(request, 'Your message has been sent successfully!')
            form = ContactForm()  # Очистить форму после отправки

        return self.render_to_response({'form': form})

