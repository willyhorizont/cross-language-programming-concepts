#{
    let output = "";
    let double = (a) => {
        return (a * 2);
    };
    output = double(10);
    [#output\ ];

    let multiply = (a) => (b) => (a * b);
    let multiply-by-ten = multiply(10);
    output = multiply-by-ten(7);
    [#output\ ];
    
    let create-new-game = (initial-credit) => {
        let current-credit = initial-credit;
        [initial credit: #initial-credit];
        return (() => {
            current-credit -= 1;
            if (current-credit == 0) {
                "not enough credits";
                return;
            }
            [playing game, #current-credit credit(s) remaining];
        });
    };
    let play-game = create-new-game(3);
    play-game();
    play-game();
    play-game();
    "";
}
