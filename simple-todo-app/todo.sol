pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

contract Todo {
    /*
     * ERROR CODES
     * 100 - Unauthorized
     * 102 - task not found
     */

    modifier onlyOwner() {
        require(msg.pubkey() == tvm.pubkey(), 100);
        _;
    }

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

    function createTask(string text) public onlyOwner {
        tvm.accept();
        m_count++;
        m_tasks[m_count] = Task(m_count, text, now, false);
    }

    function updateTask(uint32 id, bool done) public onlyOwner {
        optional(Task) task = m_tasks.fetch(id);
        require(task.hasValue(), 102);
        tvm.accept();
        Task thisTask = task.get();
        thisTask.isDone = done;
        m_tasks[id] = thisTask;
    }

    function deleteTask(uint32 id) public onlyOwner {
        require(m_tasks.exists(id), 102);
        tvm.accept();
        delete m_tasks[id];
    }

    //
    // Get methods
    //

    function getTasks() public view returns (Task[] tasks) {
        string text;
        uint64 createdAt;
        bool isDone;

        for((uint32 id, Task task) : m_tasks) {
            text = task.text;
            createdAt = task.createdAt;
            isDone = task.isDone;
            tasks.push(Task(id, text, createdAt, isDone));
       }
    }

    function getStat() public view returns (Stat stat) {
        uint32 completeCount;
        uint32 incompleteCount;

        for((uint32 id, Task task) : m_tasks) {
            if  (task.isDone) {
                completeCount ++;
            } else {
                incompleteCount ++;
            }
        }
        stat = Stat( completeCount, incompleteCount );
    }
}

