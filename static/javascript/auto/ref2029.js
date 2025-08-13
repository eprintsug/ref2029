document.observe("dom:loaded",function(){
if(document.querySelector('.ref2029_review_copy')){
  const copy_items = document.body.querySelectorAll('.ref2029_review_copy');
  for(let copy_item of copy_items) {
    // Share must be triggered by "user activation"
    copy_item.addEventListener("click", async (e) => {
      try {
         const text = e.target.dataset.text;
         navigator.clipboard.writeText(text);
      } catch (err) {
      }
    });
  }
}
});
