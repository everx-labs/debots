pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

contract Todo {
    /*
     * ERROR CODES
     * 101 - Unauthorized
     * Contract specific (12X):
     */

    uint256 m_ownerPubkey;
    uint64 m_buyerClaimsTransferTs;

    uint32 m_count;

    struct Task {
        uint32 id;
        string text;
        uint64 createdAt;
        bool isDone;
    }
 
    struct Stat {
        uint32 completeCount;
        uint32 incompleteCount;
    }
    
    
    mapping(uint32 => Task) m_tasks;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();

        m_ownerPubkey = pubkey;
    }

 
    function fn() public {
        require(msg.pubkey() == m_ownerPubkey, 101);
        tvm.accept();
        m_buyerClaimsTransferTs = now;
    }

    
    function createTask(string text) public {
        require(msg.pubkey() == m_ownerPubkey, 101);
        tvm.accept();
        m_count ++;
        m_tasks[m_count] = Task(m_count, text, now, false);
    }

    function updateTask(uint32 id, bool done) public {
        require(msg.pubkey() == m_ownerPubkey, 101);
        tvm.accept();

        optional(Task) task = m_tasks.fetch(id);
        bool exists = task.hasValue();
        require(exists, 102);

        Task thisTask = task.get();
        thisTask.isDone = done;
        m_tasks[id] = thisTask;
    }

    function deleteTask(uint32 id) public {
        require(msg.pubkey() == m_ownerPubkey, 101);
        tvm.accept();
        optional(Task) task = m_tasks.fetch(id);
        bool exists = task.hasValue();
        require(exists, 102);

        delete m_tasks[id];
    }




    function getTasks() public view returns (Task[] tasks) {
        tvm.accept();
        string text;
        uint64 createdAt;
        bool isDone;

        optional(uint32, Task) pair = m_tasks.min();

        while (pair.hasValue()) {
            (uint32 id, Task task) = pair.get();
            text = task.text;
            createdAt = task.createdAt;
            isDone = task.isDone;

            tasks.push(Task(id, text, createdAt, isDone));
            pair = m_tasks.next(id);
       }
    }

    function getStat() public view returns (Stat stat) {
        tvm.accept();
        uint32 completeCount;
        uint32 incompleteCount;
        optional(uint32, Task) pair = m_tasks.min();

        while (pair.hasValue()) {
            (uint32 id, Task task) = pair.get();
            if  (task.isDone) {
                completeCount ++;   
            } else {
                incompleteCount ++;
            }
            pair = m_tasks.next(id);
        }
        stat = Stat( completeCount, incompleteCount );
    }
}

