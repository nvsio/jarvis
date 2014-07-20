function checkForEmail(hovered)
{
	if (hovered == 15)
	{
		$('#emailModal').reveal({
		     animation: 'fade',                   //fade, fadeAndPop, none
		     animationspeed: 300,                       //how fast animtions are
		     closeonbackgroundclick: true,              //if you click background will modal close?
		});
		return true;
	}
	return false;
}

$(document).ready(function() {
	var hasMouseMoved = false;
	var replaced = false;
	var hovered = 0;

	$('body').mousemove(function()
	{
		hasMouseMoved = true;
	});

	$('.description').mouseover(function()
	{
		if (hasMouseMoved)
		{
			$('.text').each(function(index, elem)
			{
				$(elem).addClass('darker');
			});

			$(this).find('.text').removeClass('darker');
			replaceText = $(this).find('.hover').data('replace');
			$(this).find('.hover').data('replace', $(this).find('.hover').text());

			$(this).find('.hover').text(replaceText);
			replaced = true;
		}
	});

	$('.description').mouseout(function() {
		if (hasMouseMoved && replaced)
		{
			$('.text').each(function(index, elem)
			{
				$(elem).removeClass('darker');
			});

			replaceText = $(this).find('.hover').data('replace');
			$(this).find('.hover').data('replace', $(this).find('.hover').text());
			$(this).find('.hover').text(replaceText).fadeIn();
			hovered |= parseInt($(this).data('bitmask'));
			if (checkForEmail(hovered))
			{
				hovered = 16;
			}
		}
	});
})