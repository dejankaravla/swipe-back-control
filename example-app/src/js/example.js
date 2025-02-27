import { SwipeBackControl } from 'swipe-back-control';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    SwipeBackControl.echo({ value: inputValue })
}
