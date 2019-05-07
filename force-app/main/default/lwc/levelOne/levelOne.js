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
    constructor() {
        super();
        this.template.addEventListener('keydown', this.shortcuts.bind(this));
    }

    // KEYBOARD SHORTCUTS
    shortcuts(event){
        const keycode = event.keyCode;
        switch(keycode) {
            case 75: // k key
                if(event.shiftKeyKey && event.metaKey){
                    event.preventDefault();
                    this.toggleShowKeycodes();
                    this.keys = '⇧-⌘-k'
                }
                break;
            case 50: // 2 key
                if(event.metaKey){
                    event.preventDefault();
                    this.toggleLevelTwo();
                    this.keys = '⌘-2'
                }
                break;
            default:
        }
    }
    
}