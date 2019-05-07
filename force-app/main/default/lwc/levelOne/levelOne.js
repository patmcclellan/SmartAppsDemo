import { LightningElement, api, track } from 'lwc';

export default class LevelOne extends LightningElement {
    @api recordId; 

    //configuration options
    @api showIcon;
    @api whatColor;
    @api whichObject;

    @track showLevelTwo = false;
    @track showKeycodes = false;
    @track keys = '';
    @track whichIcon = 'custom:custom5';


    get colorspec(){
        return this.whatColor.toLowerCase();
    }

    get isRecordPage(){
        return typeof this.recordId !== "undefined";
    }

    toggleLevelTwo(){
        this.showLevelTwo = !this.showLevelTwo;
    }

    toggleShowKeycodes(){
        this.showKeycodes = !this.showKeycodes;
    }

    // set up key listener
    // docs here: https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_handling
    constructor() {
        super();
        this.template.addEventListener('keydown', this.shortcuts.bind(this));
        // discussion of keydown vs keyup vs keypress can be found here:
        // https://stackoverflow.com/questions/3396754/onkeypress-vs-onkeyup-and-onkeydown
    }

    // KEYBOARD SHORTCUTS
    // get keyCodes at https://keycode.info/
    shortcuts(event){
        const keycode = event.keyCode;
        switch(keycode) {
            case 75: // k key
                if(event.shiftKey && event.metaKey){
                    //start by preventing the default action
                    event.preventDefault();
                    this.toggleShowKeycodes();
                    this.keys = '⇧-⌘-K'
                }
                // now break so that the rest of the code doesn't execute
                break;
            case 50: // 2 key
                if(event.shiftKey && event.metaKey){
                    event.preventDefault();
                    this.toggleLevelTwo();
                    this.keys = '⇧-⌘-2'
                }
                break;
            case 73: // I key
                if(event.shiftKey && event.metaKey){
                    event.preventDefault();
                    this.whichIcon = 'custom:custom1';
                    this.keys = '⇧-⌘-I'
                }
                break;
            case 79: // O key
                if(event.shiftKey && event.metaKey){
                    event.preventDefault();
                    this.whichIcon = 'custom:custom10';
                    this.keys = '⇧-⌘-O'
                }
                break;
            case 80: // P key
                if(event.shiftKey && event.metaKey){
                    event.preventDefault();
                    this.whichIcon = 'custom:custom12';
                    this.keys = '⇧-⌘-P'
                }
                break;
            default:
        }
    }
    
}